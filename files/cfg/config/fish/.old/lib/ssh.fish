alias s1p='ssh s1p -t /home/agung.sorlawan/.local/bin/fish'

alias ssh-dgx1='ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh -i ~/.ssh/sso-prosa agung.sorlawan@10.181.131.250 -t "fish""'
alias ssh-dgx2='ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh -i ~/.ssh/sso-prosa agung.sorlawan@10.181.131.251 -t "fish""'
alias ssh-dgx3='ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh -i ~/.ssh/sso-prosa agung.sorlawan@10.181.131.252 -t "/home/agung.sorlawan/.local/bin/fish""'
alias ssh-s1='ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh -i ~/.ssh/sso-prosa agung.sorlawan@10.181.131.241 -t "zsh""'

alias ssh-server1='ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "zsh"'
alias ssh-server4-text='ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh text-user@10.181.131.244"'
alias s4='ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh -i ~/.ssh/sso-prosa agung.sorlawan@10.181.131.244 -t "fish""'

alias ssh-nlp-website='ssh -i ~/.ssh/sso-prosa agung.sorlawan@34.87.190.143'

alias ssh-chatbot='ssh -i ~/.ssh/chatbot-bca tiso@35.198.196.217'
alias mount-dgx='sudo sshfs -o allow_other,IdentityFile=/home/tiso/.ssh/sso-prosa agung.sorlawan@10.181.131.251:/home/agung.sorlawan /home/tiso/documents/prosa/agung.sorlawan'
alias umount-dgx='sudo umount /home/tiso/documents/prosa/agung.sorlawan'

alias tunnel-local-server1='ssh -i ~/.ssh/sso-prosa -L 9337:localhost:9337 agung.sorlawan@43.245.191.194'
alias dgx='ssh -i ~/.ssh/sso-prosa agung.sorlawan@43.245.191.194 -t "ssh -i ~/.ssh/sso-prosa agung.sorlawan@10.181.131.251 -t "zsh""'


alias ssh-gcp1='ssh -i ~/.ssh/id_rsa_tisorlawan_gmail tiso@35.187.241.129'

alias ssh-ne='ssh -i ~/.ssh/prosa_privatekey.pem prosa@35.238.77.8'

