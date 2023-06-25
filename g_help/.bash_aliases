
#Path to this script file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#auto passphrase 
_EXPECT=$SCRIPT_DIR/.excep_pass_phrase

#request functions
_FETCH=$SCRIPT_DIR/.g_fetch
_PUSH=$SCRIPT_DIR/.g_push
_PULL=$SCRIPT_DIR/.g_pull

#help file
_HELP=$SCRIPT_DIR/.g_help


g_get_commit() {
	! _g_check_repo && return 128

	branches="$(git branch)" 
	current_branch="$(git branch --show-current)"
	arg_ref=$1
	arg_branch=$2
	if [ -z "$arg_branch" ]
	then
		_branch="$current_branch"
		echo "Are you sure? Current local branch will be rewritten (y/n)"
		read answ
		case "$answ" in
			y) ;;
			yes) ;;
			Y) ;;
			Yes) ;;
			YES) ;;
		        n) return 0;;
			*) return 1;;
		esac
	else
		_branch="$arg_branch"
	fi
	$_EXPECT $_FETCH "$PASSPH" $arg_ref $_branch
}

g_push() {
	! _g_check_repo && return 128
	$_EXPECT $_PUSH "$PASSPH" $1
}

g_pull(){
	! _g_check_repo && return 128
        $_EXPECT $_PULL "$PASSPH"
}

g_pass-phrase(){

	read -s -p "Enter passphrase for provided ssh key: " _pass
	export PASSPH=$_pass
	echo "		...Updated!"
}

g(){
	cmnd="$1"
	shift
	case "$1" in
		--pass-phrase) g_pass-phrase
			shift
			;;
	esac
	case "$cmnd" in
		help) g_help 
			return 0;;
		get-commit) g_get_commit $1 $2 
			return 0;;
		push) g_push $1
			return 0;;
		pull) g_pull
			return 0;;
		pass-phrase) g_pass-phrase
	                return 0;;
	esac	
	echo "use \'g help\' to get command list"
}

_g_check_repo(){
	if  ! git status &> /dev/null;
        then
		echo "Not a git repository."
		return 128
	fi
}

g_help(){
	cat $_HELP
}

export -f g


