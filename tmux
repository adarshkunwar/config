#~~~~~~~~~~~~~~~Environment config~~~~~~~~~~~~~~~~~
setw -g mode-keys vi                      # Use vim_keybinding in copy menu
set -g history-limit 10000                # Key 10000 lines as tmux history limit
set -g base-index 1                       # Start windows numbering at 1 instead of 0
setw -g pane-base-index 1                 # Start Pane numbering at 1 instead of 0
set -g allow-rename on                    # Allow program to rename windows automatically
set -g renumber-windows on                # Automatically renumber the windows when one is destroyed
set -g mouse on                           # Enable mouse support (click, hover, scroll)
set -g set-titles on                      # Set terminal window title to match tmux session/window
setw -g monitor-activity on               # Highlight windows with activity in the status bar
set -g focus-events on                    # Send focus events to program (useful for vim/editor reload)
set -g detach-on-destroy off              # Don't detach sessions when switching the window (switch to other one instead)
set -s escape-time 0                      # Remove delay when pressing Escape (Important for vim)
set -as terminal-features ",*:RGB"        # Enables RGB support for all terminal
set -g default-terminal ${TERM}           # Tells tmux to use the same terminal as my shell
set -g status-interval 5                  # Updates status bar every 5 second

# ~~~~~~~~~~~~~~~~~~~~~ Prefix ~~~~~~~~~~~~~~~~~~~

# Change the PREFIX to Ctrl + T
unbind C-b
set -g prefix C-t
bind C-a send-prefix                      # Send the prefix to the internal command by appending C-a. 

# Use PREFIX + r to reload the config
unbind r
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# ~~~~~~~~~~~~~~~~~~~~~ Keybinds ~~~~~~~~~~~~~~~~~~~

# -r means that the bind can repeat without entering the prefix again
# -n means taht the bind doesnt use the prefix

# Allow holding Ctrl when using prefix prefix + p/n for switching windows
bind C-p previous-window
bind C-n next-window

unbind-key -T copy-mode-vi v
bind-key -T copy-mode-vi v \
  send-keys -X begin-selection
bind-key -T copy-mode-vi 'C-v' \
  send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y\
  send-keys -X copy-pipe-and-cancel "pbcopy"
bind-key -T copy-mode-vi MouseDragEnd1Pane \
  send-keys -X copy-pipe-and-cancel "pbcopy"


bind c new-window -c '#{pane_current_path}'
bind '\' split-window -h -c '#{pane_current_path}'
bind '-' split-window -v -c '#{pane_current_path}'
bind d break-pane -d


set-option -g status-justify left
set-option -g status-left '#[bg=colour72] #[bg=colour237] #[bg=colour236] #[bg=colour235]#[fg=colour185] #S #[bg=colour236] '
set-option -g status-left-length 16
set-option -g status-bg colour237
set-option -g status-right '#[bg=colour236] #[bg=colour235]#[fg=colour185] %a %R #[bg=colour236]#[fg=colour3] #[bg=colour237] #[bg=colour72] #[]'
set-option -g status-interval 60

set-option -g pane-active-border-style fg=colour246
set-option -g pane-border-style fg=colour238

set-window-option -g window-status-format '#[bg=colour238]#[fg=colour107] #I #[bg=colour239]#[fg=colour110] #[bg=colour240]#W#[bg=colour239]#[fg=colour195]#F#[bg=colour238] '
set-window-option -g window-status-current-format '#[bg=colour236]#[fg=colour215] #I #[bg=colour235]#[fg=colour167] #[bg=colour234]#W#[bg=colour235]#[fg=colour195]#F#[bg=colour236] '

