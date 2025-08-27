# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
jf config use academy

INSTRUQT_PARTICIPANT_ID=$(env | grep 'INSTRUQT_PARTICIPANT_ID')

jf -v
git -v
java -version
mvn -v
node -v 
npm -v
python -V
pip -V