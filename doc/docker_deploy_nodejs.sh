#!/bin/bash
# $# �Ǵ����ű��Ĳ�������
# $0 �ǽű����������
# $1 �Ǵ��ݸ���shell�ű��ĵ�һ������
# $2 �Ǵ��ݸ���shell�ű��ĵڶ�������
# $@ �Ǵ����ű������в������б�
# $* ����һ�����ַ�����ʾ������ű����ݵĲ�������λ�ñ�����ͬ�������ɳ���9��
# $$ �ǽű����еĵ�ǰ����ID��
# $? ����ʾ���������˳�״̬��0��ʾû�д���������ʾ�д���

# �������
MYAPPS_DIR="/opt/docker/webapps"
PRJECT_MARSTER=$1
PRJECT_NAME=$2
API_VERSION='1.0.0'
API_PORT=$3
SOURCE_PORT=$4
PROJECT_ENV=$5
PACKAGE=$PRJECT_NAME".rar"
#$BUILD_NUMBER
LAST_TAG=$6
#VIRTUAL_DIR=$7
PRE_TAG=$((LAST_TAG-1))
HARBOR_HOST=172.16.4.130
IMAGE_NAME=$HARBOR_HOST/$PRJECT_MARSTER/$PRJECT_NAME
CONTAINER_NAME=$PRJECT_MARSTER-$PRJECT_NAME-$API_VERSION
echo "================begin deploy==================="
#������
if [ $# < 6 ]; then
	echo "The number of input parameters is insufficient"
	exit 1
else
	echo "parameters ok"
fi
#�������
echo "-------start print parameters----------"
for key in "$@"
do
    echo '$@' $key
done
echo "-------end print parameters------"
#���Ŀ¼�ļ�
if [ ! -f $MYAPPS_DIR/$PRJECT_MARSTER/$PRJECT_NAME/Dockerfile ]; then
    echo $MYAPPS_DIR/$PRJECT_MARSTER/$PRJECT_NAME/Dockerfile" is not exist"
    exit 1
fi

#
chmod 777 $MYAPPS_DIR/$PRJECT_MARSTER/$PRJECT_NAME/static
cp $MYAPPS_DIR/$PRJECT_MARSTER/$PRJECT_NAME/appConfig.js $MYAPPS_DIR/$PRJECT_MARSTER/$PRJECT_NAME/static/

#ɾ��ͬ��docker����
echo "delete docker container "$CONTAINER_NAME
cid=$(docker ps -a | grep -w "$CONTAINER_NAME" | awk '{print $1}')
echo $cid
if [ "$cid" != "" ]; then
   docker stop $cid
   docker rm -f $cid
fi

#ɾ��ͬ��docker����
echo "delete docker images "$IMAGE_NAME:$PRE_TAG
imageid=$(docker images -a | grep -w "$IMAGE_NAME" | awk '{print $3}')
echo $imageid
if [ "$cid" != "" ]; then
   docker rmi -f $imageid
fi
#docker rmi -f $IMAGE_NAME:$PRE_TAG
#docker image prune -a -f

#ɾ�� Dockerfile �ļ�
#rm -f Dockerfile

#����docker ���������
echo "-------start create docker image and container------"
echo $MYAPPS_DIR/$PRJECT_MARSTER/$PRJECT_NAME
cd $MYAPPS_DIR/$PRJECT_MARSTER/$PRJECT_NAME/
#��������
echo "create docker image "$IMAGE_NAME:$LAST_TAG
docker build -t $IMAGE_NAME:$LAST_TAG .
imageid=$(docker images | grep -w "$IMAGE_NAME" | awk '{print $3}')
if [ "$imageid" = "" ]; then
   echo "create docker image "$IMAGE_NAME:$LAST_TAG" failed"
   exit 1
fi


#����docker ����
echo "start docker container "$CONTAINER_NAME
docker run -d -p $API_PORT:$SOURCE_PORT --name $CONTAINER_NAME $IMAGE_NAME:$LAST_TAG
cid=$(docker ps | grep -w "$CONTAINER_NAME" | awk '{print $1}')
if [ "$cid" = "" ]; then
   echo "start docker container "$CONTAINER_NAME" failed"
   exit 1
fi

echo "-------end create docker image and container------"
#����docker image �� Harbor
#echo $PROJECT_ENV
if [ "$PROJECT_ENV" = "pod" ]; then
	echo "-------start push docker image to Harbor------"
	#is_contaioner=${curl -i -s -k http://$HARBOR_HOST}
	#if [ $is_contaioner -ne 200 ]; then
		#docker tag $IMAGE_NAME $HARBOR_HOST/$IMAGE_NAME
		docker login -u admin -p 123456 http://$HARBOR_HOST
		docker push $IMAGE_NAME:$LAST_TAG
		#docker rmi $IMAGE_NAME
	#else
		#echo "Harbor image is exist,do not upload"
	#fi
	echo "-------end push docker image to Harbor------"
fi
echo deploy ok
echo "================end deploy==================="