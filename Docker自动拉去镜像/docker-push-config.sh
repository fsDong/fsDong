#!/bin/bash
上传镜像到镜像仓库，可选更新配置文件
## 格式：docker-push-config.sh <镜像文件> [配置文件]
registry=$(docker info | grep 60080 | tr -d ' ')
## 导入镜像
echo "镜像导入中..."
docker load -i $1 &> /dev/null
echo "镜像导入已完成！"
# 获取镜像信息文件
tar xf $1 repositories &> /dev/null
# 提取完整的镜像名+版本号，如：docker.oa.com:8080/tmf/tmf-elk-filebeat:2.0
imageOld=$(awk -F'"' '{print $2":"$4}' repositories)
echo "原来的镜像信息为: "${imageOld}
# 获取最终有用部分镜像名+版本号，如：tmf-elk-filebeat:2.0
imageNew=$(echo $imageOld | awk -F/ '{print $NF}')
# 转换要上传的镜像名
imagePush=${registry}/${imageNew}
echo "最终的镜像信息为: "${imagePush}
## 上传镜像
docker tag ${imageOld} ${imagePush}
echo "镜像上传中..."
docker push ${imagePush} &> /dev/null
echo "镜像上传已完成！"
rm -f repositories
## 更新配置（可选）
if [ $2 ]; then
echo "配置文件更新中..."
echo "配置文件更新前："
grep image: $2
echo "配置文件更新后："
sed -ri "s#^(^\ +image: ).*#\1${imagePush}#" $2
grep image: $2
fi

