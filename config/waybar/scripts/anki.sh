#!/bin/bash

DB=$(find "$HOME/.local/share/Anki2" -name collection.anki2 | head -n 1)

if [ ! -f "$DB" ]; then
    echo '{"text":"󰠮 ?","tooltip":"Anki database not found"}'
    exit 0
fi

today=$(sqlite3 "$DB" "
SELECT CAST((strftime('%s','now') - crt) / 86400 AS INTEGER)
FROM col;
")

due_reviews=$(sqlite3 "$DB" "
SELECT COUNT(*)
FROM cards
WHERE queue = 2
AND due <= $today;
")

learning=$(sqlite3 "$DB" "
SELECT COUNT(*)
FROM cards
WHERE queue = 1;
")

new_cards=$(sqlite3 "$DB" "
SELECT COUNT(*)
FROM cards
WHERE queue = 0;
")

remaining=$((due_reviews + learning + new_cards))

printf '{"text":"󰠮 %s","tooltip":"Reviews: %s\nLearning: %s\nNew: %s"}\n' \
    "$remaining" \
    "$due_reviews" \
    "$learning" \
    "$new_cards"
