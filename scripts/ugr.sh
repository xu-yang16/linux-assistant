#!/bin/bash

# 检查是否提供了新的远程仓库网址作为参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <new_remote_url>"
    exit 1
fi

# 新的远程仓库网址
NEW_REMOTE_URL=$1

# 从git获取当前的远程origin网址
CURRENT_REMOTE_URL=$(git remote get-url origin)

# 打印当前的远程仓库网址
echo "Current remote URL is: $CURRENT_REMOTE_URL"

# 添加新的远程仓库网址
git remote set-url origin --add $NEW_REMOTE_URL

# 删除旧的远程仓库网址
git remote set-url origin --delete $CURRENT_REMOTE_URL

# 打印更新后的远程仓库网址
echo "Updated remote URLs:"
git remote -v
