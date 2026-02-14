#!/usr/bin/env bash

SESSION=acm
WORKDIR=$HOME/acm/

# 如果 session 已存在，直接 attach
tmux has-session -t $SESSION 2>/dev/null && {
  tmux attach -t $SESSION
  exit 0
}

# 1. 新建 session + 第一个 window（main）
tmux new-session -d -s $SESSION -n main -c "$WORKDIR"

# 2. 在 main window 中拆分 pane
# 先左右分，左边 70%，右边 30%
tmux split-window -h -t $SESSION:main -p 30 -c "$WORKDIR"

# 再把右侧竖着分成上下两块（各 50%）
tmux split-window -v -t $SESSION:main.1 -c "$WORKDIR"

# 3. 在左侧 pane 打开 vim（不做任何事）
tmux send-keys -t $SESSION:main.0 "vim" C-m

# 4. 创建第二个 window（备用）
tmux new-window -t $SESSION -n extra -c "$WORKDIR"

# 5. 切回 main window 并 attach
tmux select-window -t $SESSION:main
tmux attach -t $SESSION
