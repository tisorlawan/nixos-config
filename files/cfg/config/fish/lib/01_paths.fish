set -x PATH "$HOME/.local/bin" $PATH
set -x PATH "$HOME/.scripts" $PATH
set -x PATH "$HOME/.cargo/bin" $PATH
set -x PATH "$HOME/.bun/bin" $PATH
set -x PATH "$PATH" "$HOME/.local/share/nvim/mason/bin"
set -x PATH "$HOME/.emacs.d/bin" $PATH
set -x PATH "$HOME/.local/share/gem/ruby/3.3.0/bin" $PATH

set -x ANDROID_HOME "$HOME/Android/Sdk"
set -x PATH "$PATH" "$ANDROID_HOME/emulator"
set -x PATH "$PATH" "$ANDROID_HOME/platform-tools"


set -x JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
set -x PATH $JAVA_HOME/bin $PATH


# set -x PATH "$HOME/.cache/npm/global/bin" $PATH
