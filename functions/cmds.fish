function cmds --description "Menú interactivo de comandos frecuentes con fzf"
    # ── Colores ANSI ────────────────────────────────────────────────────────
    set -g _C_GREEN  (printf '\033[38;5;114m')
    set -g _C_RED    (printf '\033[38;5;203m')
    set -g _C_GRAY   (printf '\033[38;5;244m')
    set -g _C_PURPLE (printf '\033[38;5;141m')
    set -g _C_BLUE   (printf '\033[38;5;117m')
    set -g _C_ORANGE (printf '\033[38;5;208m')
    set -g _C_PINK   (printf '\033[38;5;183m')
    set -g _C_BOLD   (printf '\033[1m')
    set -g _C_DIM    (printf '\033[2m')
    set -g _C_RESET  (printf '\033[0m')
    set -g _CMDS_THEME "fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa,fg+:#cdd6f4,bg+:#313244,hl+:#89dceb,info:#cba6f7,prompt:#89b4fa,pointer:#f5c2e7,marker:#a6e3a1,border:#585b70,header:#6c7086,preview-fg:#cdd6f4,preview-bg:#181825,label:#cba6f7,query:#cdd6f4"
    set -g _CMDS_HEADER_MAIN (printf '  \033[38;5;117menter\033[0m ejecutar  \033[38;5;141ma\033[0m añadir  \033[38;5;183me\033[0m editar  \033[38;5;203md\033[0m eliminar  \033[38;5;244m?\033[0m preview')
    set -g _CMDS_HEADER_DEL  (printf '  \033[38;5;244mTab\033[0m seleccionar varios')

    set data_file ~/.config/fish/cmds_data.tsv

    if not test -f $data_file
        printf "%s\t%s\n" \
            "Git: Configurar user y email" 'git config user.name "Nombre" && git config user.email "email@ejemplo.com"' \
            "Git: Ver estado"              "git status" \
            "Git: Ver ramas remotas"       "git branch -r" \
            "Git: Limpiar ramas mergeadas" "git branch --merged | grep -v main | xargs git branch -d" \
            "Sistema: Listar puertos"      "lsof -i -P -n | grep LISTEN" \
            "Sistema: Ver uso de disco"    "df -h" > $data_file
    end

    # Subcomandos internos usados por fzf execute+reload
    switch $argv[1]
        case add __add;        _cmds_add $data_file;                     return
        case edit;             _cmds_edit $data_file "";                 return
        case del delete rm;    _cmds_del $data_file;                     return
        case help --help -h;   _cmds_help;                               return
        case __list;           _cmds_colorize $data_file;                return
        case __edit
            set raw (cat /tmp/.cmds_sel 2>/dev/null)
            if test -n "$raw"
                _cmds_edit $data_file (_cmds_strip_ansi $raw)
            end
            return
        case __del
            set raws (cat /tmp/.cmds_sel 2>/dev/null)
            if test -n "$raws"
                set sel_list
                for r in $raws
                    set sel_list $sel_list (_cmds_strip_ansi $r)
                end
                _cmds_del_lines $data_file $sel_list
            end
            return
    end

    # ── Menú principal — shortcuts via execute+reload, fzf no se cierra ──────
    set sel (_cmds_colorize $data_file | fzf \
        --ansi \
        --delimiter="\t" \
        --with-nth=1 \
        --color="$_CMDS_THEME" \
        --border=rounded \
        --border-label=" ❯ cmds " \
        --border-label-pos=3 \
        --prompt="  ❯ " \
        --pointer="▶" \
        --marker="◉" \
        --info=inline \
        --height=60% \
        --header=$_CMDS_HEADER_MAIN \
        --preview='printf "\033[38;5;183m  ❯ Comando\033[0m\n\n    \033[38;5;117m%s\033[0m\n" "$(echo {} | cut -f2)"' \
        --preview-window="down:4:border-top:hidden" \
        --bind="?:toggle-preview" \
        --bind="a:execute(fish -c 'cmds __add')+reload(fish -c 'cmds __list')" \
        --bind="e:execute(echo {} > /tmp/.cmds_sel; fish -c 'cmds __edit')+reload(fish -c 'cmds __list')" \
        --bind="d:execute(printf '%s\n' {+} > /tmp/.cmds_sel; fish -c 'cmds __del')+reload(fish -c 'cmds __list')" \
        --multi)

    if test -n "$sel"
        set cmd (printf '%s' (_cmds_strip_ansi $sel) | cut -f2)
        commandline -r $cmd
    end
end

# ── Helpers de UI ─────────────────────────────────────────────────────────────

function _cmds_ok -a msg
    printf "%s  ✓%s %s%s%s\n" $_C_GREEN $_C_RESET $_C_BOLD $msg $_C_RESET
end

function _cmds_cancel
    printf "%s  ↩ Cancelado%s\n" $_C_GRAY $_C_RESET
end

function _cmds_hint -a msg
    printf "%s  %s%s\n" $_C_DIM $msg $_C_RESET
end

function _cmds_form_header -a action
    set bar (string repeat -n 46 ─)
    printf "\n"
    printf "%s  ╭%s╮%s\n"                                                         $_C_PURPLE $bar $_C_RESET
    printf "%s  │%s  %s❯ cmds%s — %-36s%s│%s\n"  $_C_PURPLE $_C_RESET $_C_PINK $_C_RESET $action $_C_PURPLE $_C_RESET
    printf "%s  │%s  %sCtrl-C para cancelar%s                       %s│%s\n"       $_C_PURPLE $_C_RESET $_C_DIM $_C_RESET $_C_PURPLE $_C_RESET
    printf "%s  ╰%s╯%s\n\n"                                                        $_C_PURPLE $bar $_C_RESET
end

# Input via fzf — $argv[1]=label, $argv[2]=valor inicial
function _cmds_input -a label initial
    # Pipe un item vacío para que fzf acepte con Enter (status 0)
    set result (printf '\n' | fzf \
        --print-query \
        --no-info \
        --no-sort \
        --query="$initial" \
        --color="$_CMDS_THEME" \
        --border=rounded \
        --border-label=" ❯ cmds " \
        --border-label-pos=3 \
        --prompt="$label" \
        --pointer="▶" \
        --height=40% \
        --bind="enter:accept" \
        --bind="esc:abort" \
        --header="Enter confirmar  Esc cancelar" \
        --no-multi)
    set s $status
    # --print-query siempre pone el query en result[1], independiente del status
    printf '%s' $result[1]
    # 0=aceptó item, 1=no match pero query existe → ambos son OK
    # 130=Esc (abort) → cancelar
    if test $s -eq 130
        return 1
    end
    return 0
end

# Strip ANSI usando el carácter ESC real en sed
function _cmds_strip_ansi
    printf '%s' $argv | LC_ALL=C sed "s/$(printf '\033')\[[0-9;]*m//g"
end

# Coloriza el prefijo de categoría para el listado de fzf
function _cmds_colorize -a data_file
    while read -l line
        set parts (string split -m1 \t $line)
        test (count $parts) -lt 2; and continue
        set title $parts[1]
        set cmd   $parts[2]
        set cat   (string match -r '^[^:]+' $title)
        switch $cat
            case Git;            set color $_C_PURPLE
            case Sistema System; set color $_C_ORANGE
            case Docker;         set color $_C_BLUE
            case npm Node JS;    set color $_C_GREEN
            case '*';            set color $_C_PINK
        end
        set colored (string replace -- $cat "$color$cat$_C_RESET" $title)
        printf '%s\t%s\n' $colored $cmd
    end < $data_file
end

# ── Operaciones CRUD ──────────────────────────────────────────────────────────

function _cmds_add -a data_file
    set title (_cmds_input "  Título  ❯ " "")
    if test -z "$title"; _cmds_cancel; return; end
    set cmd (_cmds_input "  Comando ❯ " "")
    if test -z "$cmd";   _cmds_cancel; return; end
    printf "%s\t%s\n" $title $cmd >> $data_file
    _cmds_ok "Añadido: $title"
end

function _cmds_edit -a data_file selected
    if test -z "$selected"
        set raw (_cmds_colorize $data_file | fzf \
            --ansi --delimiter="\t" --with-nth=1 \
            --color=$_CMDS_THEME --border=rounded \
            --border-label=" ❯ cmds " --border-label-pos=3 \
            --prompt="  Editar ❯ " --pointer="▶" --info=inline --height=50% \
            --preview='printf "\033[38;5;183m  ❯ Comando\033[0m\n\n    \033[38;5;117m%s\033[0m\n" "$(echo {} | cut -f2)"' \
            --preview-window="down:4:border-top")
        if test -z "$raw"; return; end
        set selected (_cmds_strip_ansi $raw)
    end

    set old_title (printf '%s' $selected | cut -f1)
    set old_cmd   (printf '%s' $selected | cut -f2)

    set new_title (_cmds_input "  Título  ❯ " "$old_title")
    if test $status -ne 0; _cmds_cancel; return; end
    set new_cmd (_cmds_input "  Comando ❯ " "$old_cmd")
    if test $status -ne 0; _cmds_cancel; return; end

    test -z "$new_title" && set new_title $old_title
    test -z "$new_cmd"   && set new_cmd   $old_cmd

    set temp (mktemp)
    while read -l line
        if test "$line" = "$selected"
            printf "%s\t%s\n" $new_title $new_cmd
        else
            printf "%s\n" $line
        end
    end < $data_file > $temp
    mv $temp $data_file
    _cmds_ok "Actualizado: $new_title"
end

function _cmds_del -a data_file
    set raws (_cmds_colorize $data_file | fzf \
        --ansi --delimiter="\t" --with-nth=1 \
        --color=$_CMDS_THEME --border=rounded \
        --border-label=" ❯ cmds " --border-label-pos=3 \
        --prompt="  Eliminar ❯ " --pointer="▶" --marker="◉" \
        --info=inline --height=50% --multi \
        --header=$_CMDS_HEADER_DEL \
        --preview='printf "\033[38;5;183m  ❯ Comando\033[0m\n\n    \033[38;5;117m%s\033[0m\n" "$(echo {} | cut -f2)"' \
        --preview-window="down:4:border-top")
    if test -z "$raws"; return; end
    set selected_list
    for r in $raws
        set selected_list $selected_list (_cmds_strip_ansi $r)
    end
    _cmds_del_lines $data_file $selected_list
end

function _cmds_del_lines -a data_file
    set lines $argv[2..-1]
    set temp (mktemp)
    while read -l line
        set keep 1
        for sel in $lines
            if test "$line" = "$sel"
                set keep 0; break
            end
        end
        test $keep -eq 1; and printf "%s\n" $line
    end < $data_file > $temp
    mv $temp $data_file
    _cmds_ok "Eliminado(s): "(count $lines)" comando(s)"
end

# ── Help ──────────────────────────────────────────────────────────────────────

function _cmds_help
    printf "\n"
    printf "%s  ╭─────────────────────────────────╮%s\n" $_C_PURPLE $_C_RESET
    printf "%s  │%s  %s%scmds%s  %sdashboard de comandos%s  %s│%s\n" $_C_PURPLE $_C_RESET $_C_BOLD $_C_PINK $_C_RESET $_C_DIM $_C_RESET $_C_PURPLE $_C_RESET
    printf "%s  ╰─────────────────────────────────╯%s\n" $_C_PURPLE $_C_RESET
    printf "\n"
    printf "  %sMenú interactivo%s\n" $_C_BOLD $_C_RESET
    printf "  %s  enter  %s  Ejecutar comando\n"    $_C_BLUE   $_C_RESET
    printf "  %s  ctrl-a %s  Añadir nuevo\n"        $_C_PURPLE $_C_RESET
    printf "  %s  ctrl-e %s  Editar seleccionado\n" $_C_PINK   $_C_RESET
    printf "  %s  ctrl-d %s  Eliminar seleccionado\n" $_C_RED  $_C_RESET
    printf "  %s  ?      %s  Mostrar/ocultar preview\n" $_C_GRAY $_C_RESET
    printf "  %s  esc    %s  Salir\n"               $_C_GRAY   $_C_RESET
    printf "\n"
    printf "  %sSubcomandos%s\n" $_C_BOLD $_C_RESET
    printf "  %scmds add | edit | del | help%s\n"   $_C_DIM    $_C_RESET
    printf "\n"
    printf "  %sDatos: ~/.config/fish/cmds_data.tsv%s\n" $_C_DIM $_C_RESET
    printf "\n"
end
