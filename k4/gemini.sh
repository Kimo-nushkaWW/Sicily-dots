#!/usr/bin/env bash
# Небольшой адаптер Gemini для K4.
# Ключ берётся из GEMINI_API_KEY/GOOGLE_API_KEY или из
# ~/.config/environment.d/gemini.conf. В репозитории ключа нет.
set -euo pipefail

prompt=${1:-}
image=${2:-}
session=${3:-}
workdir=${ASK_DIR:-/tmp/k4-ask}

mkdir -p "$workdir"

read_env_key() {
    local key_file=$1 key_name=$2
    [ -r "$key_file" ] || return 0
    sed -n "s/^${key_name}=//p" "$key_file" | head -n 1
}

api_key=${GEMINI_API_KEY:-${GOOGLE_API_KEY:-}}
if [ -z "$api_key" ]; then
    api_key=$(read_env_key "$HOME/.config/environment.d/gemini.conf" GEMINI_API_KEY)
fi
if [ -z "$api_key" ]; then
    api_key=$(read_env_key "$HOME/.config/environment.d/gemini.conf" GOOGLE_API_KEY)
fi

if [ -z "$api_key" ]; then
    jq -cn '{type:"error",error:{message:"Не найден GEMINI_API_KEY. Настройте ~/.config/environment.d/gemini.conf (chmod 600) и перезапустите K4."}}'
    exit 0
fi

if [ -z "$session" ]; then
    session=$(uuidgen)
fi

history_file="$workdir/gemini-${session}.json"
if [ -s "$history_file" ] && jq -e 'type == "array"' "$history_file" >/dev/null 2>&1; then
    history=$(cat "$history_file")
else
    history='[]'
fi

mime=""
image_data=""
if [ -n "$image" ] && [ -r "$image" ]; then
    case "$image" in
        *.jpg|*.jpeg|*.JPG|*.JPEG) mime="image/jpeg" ;;
        *.webp|*.WEBP) mime="image/webp" ;;
        *.gif|*.GIF) mime="image/gif" ;;
        *) mime="image/png" ;;
    esac
    image_data=$(base64 -w 0 "$image")
fi

user_content=$(jq -cn \
    --arg prompt "$prompt" \
    --arg mime "$mime" \
    --arg data "$image_data" \
    'if $data != ""
     then {role:"user",parts:[{text:$prompt},{inline_data:{mime_type:$mime,data:$data}}]}
     else {role:"user",parts:[{text:$prompt}]}
     end')

contents=$(jq -cn --argjson history "$history" --argjson user "$user_content" '$history + [$user]')
payload=$(jq -cn --argjson contents "$contents" \
    '{systemInstruction:{parts:[{text:"Отвечай на русском языке, если пользователь явно не попросил другой язык."}]},contents:$contents,generationConfig:{temperature:0.7}}')

# Keep the override for compatibility, but use a currently supported default.
model=${GEMINI_MODEL:-gemini-3.6-flash}
config_file=$(mktemp "$workdir/curl.XXXXXX")
trap 'rm -f "$config_file"' EXIT
chmod 600 "$config_file"
printf 'header = "Content-Type: application/json"\nheader = "x-goog-api-key: %s"\n' "$api_key" > "$config_file"

if ! response=$(curl -sS \
    --config "$config_file" \
    --connect-timeout 10 \
    --max-time 120 \
    -X POST \
    "https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent" \
    --data-binary "$payload" 2>&1); then
    jq -cn --arg message "$response" \
        '{type:"error",error:{message:("Не удалось связаться с Gemini: " + $message)}}'
    exit 0
fi

error=$(printf '%s' "$response" | jq -r '.error.message // empty' 2>/dev/null || true)
if [ -n "$error" ]; then
    jq -cn --arg message "$error" '{type:"error",error:{message:$message}}'
    exit 0
fi

answer=$(printf '%s' "$response" | jq -r '[.candidates[0].content.parts[]?.text // empty] | join("\n")' 2>/dev/null || true)
if [ -z "$answer" ]; then
    jq -cn '{type:"error",error:{message:"Gemini вернул пус��ой ответ. Проверьте модель и API key."}}'
    exit 0
fi

next_history=$(jq -cn \
    --argjson history "$contents" \
    --arg answer "$answer" \
    '$history + [{role:"model",parts:[{text:$answer}]}]')
printf '%s\n' "$next_history" > "$history_file"
chmod 600 "$history_file"

jq -cn --arg id "$session" '{type:"thread.started",thread_id:$id}'
jq -cn --arg text "$answer" \
    '{type:"item.completed",item:{type:"agent_message",text:$text}}'
jq -cn '{type:"turn.completed"}'
