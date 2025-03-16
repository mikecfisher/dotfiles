function lld --wraps='exa_git $EXA_LD_OPTIONS' --wraps='eza_git $EZA_LD_OPTIONS' --description 'alias lld eza_git $EZA_LD_OPTIONS'
  eza_git $EZA_LD_OPTIONS $argv
        
end
