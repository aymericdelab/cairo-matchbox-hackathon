docker run -dit -v "$PWD":"$PWD" -w "$PWD" -p 5050:5050 --name test cairo:cmd 
docker exec -it test /bin/sh
