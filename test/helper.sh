

echo_green(){
  echo -e "\t\e[32m $1 \e[m"
  return 0
}

echo_red() {
  echo -e "\t\e[31m $1 \e[m"
  return 0
}

echo_indent(){
  echo -e "\t" $1 $2
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	return 0
fi