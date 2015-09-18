#/usr/bin/env bash
# @Function
# show all console text color themes.

colorEcho() {
    local combination="$1"
    shift 1
    [ -c /dev/stdout ] && {
        echo -e -n "\033[${combination}m"
        echo -e -n "$@"
        echo -e "\033[0m"
    } || echo "$@"
}

colorEchoWithoutNewLine() {
    local combination="$1"
    shift 1
    [ -c /dev/stdout ] && {
        echo -e -n "\033[${combination}m"
        echo -e -n "$@"
        echo -e -n "\033[0m"
    } || echo -n "$@"
}

if ! command -v zgrep &> /dev/null; then
    zgrep() {
        zcat "$2" | grep "$1"
    }
fi

# see https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
declare -A colors=(
    [black]=30
    [red]=31
    [green]=32
    [yellow]=33
    [blue]=34
    [magenta]=35
    [cyan]=36
    [white]=37
)

color() {
    color=()
    if [ "$1" = 'bold' ]; then
        color+=( '1' )
        shift
    fi
    if [ $# -gt 0 ] && [ "${colors[$1]}" ]; then
        color+=( "${colors[$1]}" )
    fi
    local IFS=';'
    echo -en '\033['"${color[*]}"m
}

wrap_color() {
    text="$1"
    shift
    color "$@"
    echo -n "$text"
    color reset
    echo
}

wrap_good() {
    echo "$(wrap_color "$1" white): $(wrap_color "$2" green)"
}

wrap_bad() {
    echo "$(wrap_color "$1" bold): $(wrap_color "$2" bold red)"
}

wrap_warning() {
    wrap_color >&2 "$*" red
}

check_flag() {
    if is_set_in_kernel "$1"; then
        wrap_good "CONFIG_$1" 'enabled'
    elif is_set_as_module "$1"; then
        wrap_good "CONFIG_$1" 'enabled (as module)'
    else
        wrap_bad "CONFIG_$1" 'missing'
    fi
}

check_flags() {
    for flag in "$@"; do
        echo "- $(check_flag "$flag")"
    done
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        wrap_good "$1 command" 'available'
    else
        wrap_bad "$1 command" 'missing'
    fi
}

check_device() {
    if [ -c "$1" ]; then
        wrap_good "$1" 'present'
    else
        wrap_bad "$1" 'missing'
    fi
}

possibleConfigs=(
    '/proc/config.gz'
    "/boot/config-$(uname -r)"
    "/usr/src/linux-$(uname -r)/.config"
    '/usr/src/linux/.config'
)

if [ $# -gt 0 ]; then
    CONFIG="$1"
else
    : ${CONFIG:="${possibleConfigs[1]}"}
fi

is_set() {
    zgrep "CONFIG_$1=[y|m]" "$CONFIG" > /dev/null
}
is_set_in_kernel() {
    zgrep "CONFIG_$1=y" "$CONFIG" > /dev/null
}
is_set_as_module() {
    zgrep "CONFIG_$1=m" "$CONFIG" > /dev/null
}

flags=(
    NAMESPACES {NET,PID,IPC,UTS}_NS
    DEVPTS_MULTIPLE_INSTANCES
    CGROUPS CGROUP_CPUACCT CGROUP_DEVICE CGROUP_FREEZER CGROUP_SCHED CPUSETS MEMCG
    MACVLAN VETH BRIDGE BRIDGE_NETFILTER
    NF_NAT_IPV4 IP_NF_FILTER IP_NF_TARGET_MASQUERADE
    NETFILTER_XT_MATCH_{ADDRTYPE,CONNTRACK}
    NF_NAT NF_NAT_NEEDED

    # required for bind-mounting /dev/mqueue into containers
    POSIX_MQUEUE
)
check_flags "${flags[@]}"
echo

for style in 0 1 2 3 4 5 6 7; do
    for fg in 30 31 32 33 34 35 36 37; do
        for bg in 40 41 42 43 44 45 46 47; do
            combination="${style};${fg};${bg}"
            colorEchoWithoutNewLine "$combination" "$combination"
            echo -n " "
        done
        echo
    done
    echo
done

echo "Code sample to print color text:"
echo -n '    echo -e "\033['
colorEchoWithoutNewLine "3;35;40" "1;36;41"
echo -n "m"
colorEchoWithoutNewLine "0;32;40" "Sample Text"
echo "\033[0m\""
echo "Output of above code:"
echo -e "    \033[1;36;41mSample Text\033[0m"
echo
echo "If you are going crazy to write text in escapes string like me,"
echo "you can use colorEcho and colorEchoWithoutNewLine function in this script."
echo
echo "Code sample to print color text:"
echo '    colorEcho "1;36;41" "Sample Text"'
echo "Output of above code:"
echo -n "    "
colorEcho "1;36;41" "Sample Text"
