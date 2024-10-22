source ./infra.env
docker tag $1 $REGION-docker.pkg.dev/$PROJECT/$REPO/$1
docker push $REGION-docker.pkg.dev/$PROJECT/$REPO/$1