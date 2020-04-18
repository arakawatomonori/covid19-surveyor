

echo_green(){
  echo -e "\t\e[32m $1 \e[m"
}

echo_red() {
  echo -e "\t\e[31m $1 \e[m"
}

echo_indent(){
  echo -e "\t" $1 $2
}