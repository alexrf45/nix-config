kubectl get nodes -o json |
  jq -r '
    .items[] |
    { "name": .metadata.name, "label": .metadata.labels | to_entries[] } |
    select(.label) |
    [ .name, .label.key + "=" + .label.value ] |
    @tsv
' |
  sort -k1,2
