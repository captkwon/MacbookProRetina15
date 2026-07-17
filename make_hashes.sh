#!/usr/bin/env bash
#
# 1. 현재 디렉터리와 모든 하위 디렉터리의 일반 파일을 대상으로 상대 경로, 파일 크기, SHA-256 해시값, 수정 시각을 수집한다.
# 2. 수집 결과를 SHA-256, 파일 크기, 수정 시각 오름차순으로 정렬하고, 동일한 크기와 해시값을 가진 파일 중 가장 오래된 파일은 KEEP, 나머지 파일은 DUPLICATE로 표시한 hashes.tsv를 생성한다.
# 3. 또한 각 DUPLICATE 파일을 해당 그룹의 KEEP 파일과 cmp -s로 바이트 단위 비교한 후, 완전히 동일할 때만 삭제하도록 구성된 delete_duplicates.sh를 생성한다.
# 이 스크립트 자체는 파일을 삭제하지 않는다. 처리 중에는 별도의 진행 상황을 출력하지 않으며, 실행 여부는 다음 명령으로 확인할 수 있다. $ ps aux | grep -E 'sha256sum|find'
#
set -u
set -o pipefail

output="./hashes.tsv"
commands="./delete_duplicates.sh"

list=$(mktemp) || exit 1
raw=$(mktemp) || {
    rm -f -- "$list"
    exit 1
}
checked=$(mktemp) || {
    rm -f -- "$list" "$raw"
    exit 1
}

# 도중에 종료되더라도 임시 파일 삭제
trap 'rm -f -- "$list" "$raw" "$checked"' EXIT

# ============================================================
# 1. 검사할 파일 목록 작성
#
# 이전 실행 결과인 hashes.tsv와 delete_duplicates.sh는 제외
# ============================================================

if ! find . -type f \
    ! -path "$output" \
    ! -path "$commands" \
    -print0 > "$list"
then
    printf '파일 목록 작성에 실패했습니다.\n' >&2
    exit 1
fi

# ============================================================
# 2. 각 파일의 경로, 크기, SHA-256, 수정 시각 수집
# ============================================================

{
    printf 'relative_path\tsize\tsha256\tmodified_time\tstatus\n'

    while IFS= read -r -d '' file; do
        # 경로 앞의 ./ 제거
        path=${file#./}

        if size=$(stat -c '%s' -- "$file" 2>/dev/null) &&
           modified=$(stat -c '%Y' -- "$file" 2>/dev/null) &&
           hash_output=$(sha256sum -- "$file" 2>/dev/null)
        then
            # sha256sum 결과에서 해시값만 추출
            hash=${hash_output%% *}

            printf '%s\t%s\t%s\t%s\tOK\n' \
                "$path" "$size" "$hash" "$modified"
        else
            printf '%s\t\t\t\tERROR\n' "$path"
        fi
    done < "$list"
} > "$raw"

# ============================================================
# 3. 정렬 및 중복 판정
#
# 정렬 순서:
#   SHA-256 → 크기 → 수정 시각(오래된 파일 우선) → 경로
#
# 동일한 크기와 SHA-256을 가진 그룹에서:
#   첫 번째 파일 = KEEP
#   이후 파일     = DUPLICATE
# ============================================================

if ! {
    head -n 1 "$raw"

    tail -n +2 "$raw" |
        LC_ALL=C sort -t $'\t' \
            -k3,3 \
            -k2,2n \
            -k4,4n \
            -k1,1
} |
awk '
BEGIN {
    FS = OFS = "\t"
}

NR == 1 {
    print $0, "result"
    next
}

{
    if ($5 != "OK") {
        result = "ERROR"
    }
    else if (previous_status == "OK" && $2 == previous_size && $3 == previous_hash) {
        result = "DUPLICATE"
    }
    else {
        result = "KEEP"
    }

    print $0, result

    previous_size = $2
    previous_hash = $3
    previous_status = $5
}
' > "$checked"
then
    printf '정렬 또는 중복 판정에 실패했습니다.\n' >&2
    exit 1
fi

# 완성된 결과로 기존 hashes.tsv 교체
if ! mv -- "$checked" "$output"; then
    printf '%s 생성에 실패했습니다.\n' "$output" >&2
    exit 1
fi

# ============================================================
# 4. 중복 삭제 스크립트 생성
#
# 각 DUPLICATE 파일은 바로 윗행이 아니라
# 해당 그룹의 첫 번째 KEEP 파일과 비교
#
# cmp가 실제 바이트까지 완전히 같다고 판정할 때만 삭제
# ============================================================

{
    printf '%s\n' '#!/usr/bin/env bash'
    printf '\n'
    printf '%s\n' 'set -u'
    printf '\n'

    # 어느 디렉터리에서 실행해도 스크립트가 있는 위치를 기준으로 동작
    printf '%s\n' 'script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)'
    printf '%s\n' 'cd -- "$script_dir" || exit 1'
    printf '\n'

    keep_path=""

    tail -n +2 "$output" |
    while IFS=$'\t' read -r path size hash modified status result; do
        case "$result" in
            KEEP)
                # 현재 중복 그룹의 기준 파일
                keep_path=$path
                ;;

            DUPLICATE)
                if [[ -n $keep_path ]]; then
                    printf 'sudo cmp -s -- %q %q && sudo rm -- %q\n' \
                        "$keep_path" "$path" "$path"
                fi
                ;;

            ERROR)
                # 오류 행은 비교 기준으로 사용하지 않음
                keep_path=""
                ;;
        esac
    done
} > "$commands"

chmod +x "$commands"

# 정상 종료 시 임시 파일 정리
rm -f -- "$list" "$raw"
trap - EXIT

printf '완료:\n'
printf '  판정 결과: %s\n' "$output"
printf '  삭제 명령: %s\n' "$commands"
