#!/bin/bash

# 参数:
#   SLACK_WEBHOOK: ${{ secrets.SLACK_MOBILE_WEBHOOK }}
#   SLACK_MESSAGE_TITLE: "✅ CoinEx iOS 打包成功，已上传到服务器"
#   PR_HTML_URL: ${{ github.event.pull_request.html_url }}
#   PR_NUMBER: ${{ github.event.pull_request.number }}
#   PR_TITLE: ${{ github.event.pull_request.title }}
#   PR_BODY: ${{ github.event.pull_request.body }}
#   PR_BASE_SHA: ${{ github.event.pull_request.base.sha }}
#   PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}

# 获取Body
if [ -z "$PR_BODY" ]; then
  PR_BODY="未填写⭕"
fi
PR_BODY="*Description:*\n$PR_BODY"
echo $PR_BODY

# 获取提交信息
commits=$(git log --pretty=format:"%H - %s (%an)" "$PR_BASE_SHA..$PR_HEAD_SHA")
# 提取每个提交的哈希和消息，并构建链接
formatted_commits=""
while read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  commit_message=$(echo "$line" | awk '{$1=""; print $0}')
  commit_url="$PR_HTML_URL/commits/$commit_hash"
  formatted_commit="<$commit_url|${commit_message}>"
  formatted_commits="${formatted_commits}${formatted_commit}\n"
done <<< "$commits"
formatted_commits="*Commits:*\n$formatted_commits"
echo $formatted_commits

payload_json=$(cat <<JSON
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "$SLACK_MESSAGE_TITLE",
        "emoji": true
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "点击按钮进行下载"
      },
      "accessory": {
        "type": "button",
        "text": {
          "type": "plain_text",
          "text": "下载",
          "emoji": true
        },
        "url": "http://3.33.146.9:5000/",
        "style": "primary"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "<$PR_HTML_URL|#$PR_NUMBER $PR_TITLE>"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "$PR_BODY"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "$formatted_commits"
      }
    }
  ]
}
JSON
)
echo $payload_json
payload_json=$(cat <<EOF
{
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "点击按钮进行下载"
      },
      "accessory": {
        "type": "button",
        "text": {
          "type": "plain_text",
          "text": "下载",
          "emoji": True
        },
        "url": "http://3.33.146.9:5000/",
        "style": "primary"
      }
    }
  ]
}
EOF
)
echo $payload_json
$(python3 -c "import json; print(json.dumps($payload_json))")

# echo $escaped_payload_json

# curl -X POST -H 'Content-type: application/json' --data "$escaped_payload_json" $SLACK_WEBHOOK