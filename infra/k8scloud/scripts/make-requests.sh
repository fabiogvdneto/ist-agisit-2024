# Usage: sh make-requests.sh 10 http://localhost:3000
$quantity=$1
$address=$2

for i in $(seq 1 $quantity)
do
  curl $address
done