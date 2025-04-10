#!/bin/bash

# Tool requirements
install_if_missing() {
    local cmd="$1"
    local pkg="$2"
    if ! command -v "$cmd" >/dev/null; then
        if dialog --yesno "$cmd is required. Install $pkg now?" 8 40; then
            sudo apt-get install -y "$pkg"
        else
            dialog --msgbox "$cmd is required. Exiting." 6 40
            exit 1
        fi
    fi
}

install_if_missing dialog dialog
install_if_missing xclip xclip
install_if_missing curl curl

# Settings (defaults)
REQUIRE_SYMBOLS=true
REQUIRE_UPPER=true
REQUIRE_DIGIT=true
REQUIRE_LOWER=true
MIN_LENGTH=8

# Calculate password entropy
calculate_entropy() {
    local password="$1"
    local charset=0

    [[ "$password" =~ [a-z] ]] && ((charset += 26))
    [[ "$password" =~ [A-Z] ]] && ((charset += 26))
    [[ "$password" =~ [0-9] ]] && ((charset += 10))
    [[ "$password" =~ [\!\@\#\$\%\^\&\*\(\)\-\_\=\+\[\]\{\}\|\;\:\<\>\,\.\?\/] ]] && ((charset += 32))

    local length=${#password}
    local entropy
    entropy=$(awk -v len="$length" -v set="$charset" 'BEGIN { print int(len * log(set) / log(2)) }')
    echo "$entropy"
}

# Estimate crack time
estimate_crack_time() {
    local entropy="$1"
    if (( entropy < 28 )); then
        echo "Very Weak (few seconds)"
    elif (( entropy < 36 )); then
        echo "Weak (minutes)"
    elif (( entropy < 60 )); then
        echo "Moderate (hours to days)"
    elif (( entropy < 80 )); then
        echo "Strong (months to years)"
    else
        echo "Very Strong (centuries)"
    fi
}

# HIBP check
check_hibp() {
    local password="$1"
    local sha1 prefix suffix response
    sha1=$(printf "%s" "$password" | iconv -t utf8 | sha1sum | awk '{print toupper($1)}')
    prefix="${sha1:0:5}"
    suffix="${sha1:5}"
    response=$(curl -s "https://api.pwnedpasswords.com/range/$prefix")

    if echo "$response" | grep -q "$suffix"; then
        echo "⚠️ This password has been leaked!"
    else
        echo "✅ Not found in known leaks."
    fi
}

# Toggle rules menu
configure_rules() {
    local choices
    choices=$(dialog --checklist "Password Requirements" 12 60 5 \
        "1" "Require symbols" "$([ "$REQUIRE_SYMBOLS" = true ] && echo "on" || echo "off")" \
        "2" "Require uppercase letters" "$([ "$REQUIRE_UPPER" = true ] && echo "on" || echo "off")" \
        "3" "Require digits" "$([ "$REQUIRE_DIGIT" = true ] && echo "on" || echo "off")" \
        "4" "Require lowercase letters" "$([ "$REQUIRE_LOWER" = true ] && echo "on" || echo "off")" \
        2>&1 >/dev/tty)

    REQUIRE_SYMBOLS=false
    REQUIRE_UPPER=false
    REQUIRE_DIGIT=false
    REQUIRE_LOWER=false

    [[ "$choices" =~ "1" ]] && REQUIRE_SYMBOLS=true
    [[ "$choices" =~ "2" ]] && REQUIRE_UPPER=true
    [[ "$choices" =~ "3" ]] && REQUIRE_DIGIT=true
    [[ "$choices" =~ "4" ]] && REQUIRE_LOWER=true

    MIN_LENGTH=$(dialog --inputbox "Set minimum password length:" 8 40 "$MIN_LENGTH" 2>&1 >/dev/tty)
}

# Analyze a password
analyze_password() {
    local password entropy cracktime
    password=$(dialog --insecure --passwordbox "Enter password to analyze:" 8 40 2>&1 >/dev/tty)
    [ -z "$password" ] && return

    if (( ${#password} < MIN_LENGTH )); then
        dialog --msgbox "Password must be at least $MIN_LENGTH characters long." 6 50
        return
    fi

    entropy=$(calculate_entropy "$password")
    cracktime=$(estimate_crack_time "$entropy")
    local hibp_result
    hibp_result=$(check_hibp "$password")

    echo -n "$password" | xclip -selection clipboard
    dialog --msgbox "Password: $password\n\nEntropy: $entropy\nCrack Time: $cracktime\nHIBP: $hibp_result\n\n(Copied to clipboard)" 14 60
}

# Generate a password
generate_password() {
    local length charset password entropy cracktime
    length=$(dialog --inputbox "Enter desired password length (default 16):" 8 40 "16" 2>&1 >/dev/tty)
    length=${length:-16}

    charset=""
    $REQUIRE_SYMBOLS && charset+='!@#$%^&*()_+'
    $REQUIRE_UPPER && charset+='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $REQUIRE_DIGIT && charset+='0123456789'
    $REQUIRE_LOWER && charset+='abcdefghijklmnopqrstuvwxyz'

    if [ -z "$charset" ]; then
        dialog --msgbox "No character sets selected in settings!" 6 50
        return
    fi

    password=$(tr -dc "$charset" < /dev/urandom | head -c "$length")
    entropy=$(calculate_entropy "$password")
    cracktime=$(estimate_crack_time "$entropy")

    echo -n "$password" | xclip -selection clipboard
    dialog --msgbox "Generated Password: $password\n\nEntropy: $entropy\nCrack Time: $cracktime\n(Copied to clipboard)" 12 60
}

# Analyze a batch of passwords
batch_analysis() {
    local file result pass entropy cracktime hibp_result
    file=$(dialog --title "Select Password File" --fselect "$HOME/" 14 48 2>&1 >/dev/tty) || return
    result="/tmp/pass_audit_$(date +%s).txt"

    while IFS= read -r pass; do
        entropy=$(calculate_entropy "$pass")
        cracktime=$(estimate_crack_time "$entropy")
        hibp_result=$(check_hibp "$pass")
        {
            echo "Password: $pass"
            echo "Entropy: $entropy"
            echo "Crack Time: $cracktime"
            echo "HIBP: $hibp_result"
            echo "-------------------------"
        } >> "$result"
    done < "$file"

    dialog --textbox "$result" 20 70
}

# Main menu
main_menu() {
    while true; do
        local choice
        choice=$(dialog --clear --backtitle "Password Strength Tool" \
            --title "Main Menu" \
            --menu "Choose an option:" 15 50 6 \
            1 "Analyze Password" \
            2 "Generate Password" \
            3 "Batch Analyze" \
            4 "Settings" \
            5 "Exit" \
            2>&1 >/dev/tty)

        case $choice in
            1) analyze_password ;;
            2) generate_password ;;
            3) batch_analysis ;;
            4) configure_rules ;;
            5) clear; exit ;;
        esac
    done
}

main_menu
a
