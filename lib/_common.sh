REPOS_ROOT=$(dirname $(dirname "$BASH_SOURCE"))

tokyo_datetime(){
    TZ=Asia/Tokyo date +'%Y-%m-%d %H:%M:%S %z'
}
