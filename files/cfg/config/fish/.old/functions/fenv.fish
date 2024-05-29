function fenv -d "Run bash scripts and import variables modified by them"
  if count $argv >/dev/null
    if string trim -- $argv | string length -q
      fenv.main $argv
      return $status
    end
  return 0
  else
    echo (set_color red)'error:' (set_color normal)'parameter missing'
    echo (set_color cyan)'usage:' (set_color normal)'fenv <bash command>'
    return 23  # EINVAL
  end
end
