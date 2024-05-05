function just_copy_assets_from_assets_repo {
  cd ~/projects/gd4_tb_paper_assets/krita/;
  local assets_to_move_rel_paths; assets_to_move_rel_paths=$(gfind_files ".*\.png");
  local assets_to_move_abs_paths; assets_to_move_abs_paths=$(echo "$assets_to_move_rel_paths" | sed -E "s,^(\.),${path_replace:-$PWD},");
  cd ~-;
  local assets_to_move_new_abs_paths; assets_to_move_new_abs_paths=$(echo "$assets_to_move_rel_paths" | sed -E "s,^(\.),${path_replace:-"${PWD}/art/my"},");
  local _cp_cmd;
  paste <(echo "$assets_to_move_abs_paths") <(echo "$assets_to_move_new_abs_paths") | while IFS=$'\t' read -r from to; do
     _cp_cmd="cp $from $to";
     mkdir -p "$(dirname "$to")"
     eval "$_cp_cmd";
  done
}
