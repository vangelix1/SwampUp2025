# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
jf config use academy

INSTRUQT_PARTICIPANT_ID=$(env | grep 'INSTRUQT_PARTICIPANT_ID')

JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
M2_HOME="/usr/share/maven"
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH

printf "\n ------------------------------------------------------------  "
printf "\n   ----------------    Environment Info   ----------------  "
printf "\n ------------------------------------------------------------  \n"
printf " Ubuntu $(lsb_release -a 2>&1 | grep 'Release:') \n"
printf " JFrog CLI Version: $(jf -v) \n"
printf " Git Version: $(git -v) \n"
printf " Java Version: $(java -version 2>&1 | head -n 1) \n"
# apt install maven
printf " Maven Version: $(mvn -v | head -n 1) \n"
printf " Gradle Version: $(gradle -v | grep 'Gradle ' | head -n 1) \n"
printf " Node Version: $(node -v) \n"
printf " NPM Version: $(npm -v) \n"
printf " Python Version: $(python -V 2>&1) \n"
printf " Pip Version: $(pip -V) \n"
printf " Docker Version: $(docker -v) \n"
printf "\n ------------------------------------------------------------  \n"
printf "\n SwampUp 2025 lab source code: https://github.com/jfrog/SwampUp2025  \n"
printf "\n SwampUp 2025 JFrog Platform UI credentials: "
printf "\n       Username: admin "
printf "\n       Password: Admin1234! "
printf "\n       Lab url: https://academy-artifactory \n"
printf "\n  \n"