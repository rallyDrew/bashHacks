#!/bin/bash +x

# This script will download the docker tools into your ~/.dockercli folder
# It is useful for preparing an environment for the first time docker is used
# or when new docker tools need to be installed.

# Usage: ./bootstrapDockerTools.sh
# Usage: ./bootstrapDockerTools.sh --link

mkdir -p ~/.dockercli
cd ~/.dockercli


LINKLOCATION="/usr/local/bin"
DOCKERARCH=`uname -s`/`uname -m`
echo $DOCKERARCH
echo ${1}

curl -L -Ss -o changelog.md https://raw.githubusercontent.com/docker/docker/master/CHANGELOG.md
cat changelog.md | grep "## 1" | awk -F " " '{print $2}' > ~/.dockercli/releases
echo "latest" >> releases

while read p; do
	GETURL="https://get.docker.com/builds/$DOCKERARCH/docker-${p}"
	LOCALURL=docker-${p}


	if [ -a "${LOCALURL}" ]; then
		echo "Skipping ${LOCALURL}. File exists"
	else
		echo "Downloading ${GETURL}"
		curl -L -fSs -o ${LOCALURL} ${GETURL}
	fi

	chmod +x ~/.dockercli/${LOCALURL}



	if [ -z ${MYDOCKER} ]; then
		~/.dockercli/${LOCALURL} version > ~/.dockercli/testVersion 2> ~/.dockercli/testVersionErr
		if [ $? -eq 0 ]; then
			MYDOCKER=~/.dockercli/${LOCALURL}

		fi
	fi

done <releases

rm ~/.dockercli/testVersion
rm ~/.dockercli/testVersionErr

echo "Your server seems to need: ${MYDOCKER}"

if [ "${1}" == "--link" ]; then

  rm -f ${LINKLOCATION}/docker
  rm -f ${LINKLOCATION}/docker-latest
	cp ${MYDOCKER} ${LINKLOCATION}/docker
	cp ~/.dockercli/docker-latest ${LINKLOCATION}/docker-latest
fi
