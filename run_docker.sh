docker run -dit -v "$PWD":"$PWD" -w "$PWD" --name test cairo:cmd 
docker exec -it test /bin/sh
