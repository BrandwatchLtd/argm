#! groovy

node ('docker') {
    dir ("${WORKSPACE}/build") {
        sh "install -d ${WORKSPACE}/build";
        stage ('Fetch repository') {
            git credentialsId: '9518243f-f5dd-4054-8420-d5da92a6da1e', url: 'git@github.com:BrandwatchLtd/argm.git';
        }
        stage ('Build Docker image') {
            img = docker.build('debian8-pgsql-builder');
        }
    }
    stage ('Build debian packages') {
        sh "docker run -v $WORKSPACE:/mnt --rm ${img.id} dpkg-buildpackage -b";
        sh "ls ${WORKSPACE}; ls ${WORKSPACE}/";
    }
    dir ("${WORKSPACE}")
    {
        stage ('Upload to repositories') {
            [
                'http://apt.service0.btn1.bwcom.net/packages',
                'https://aptly.stage.brandwatch.net/packages'
            ].each { aptly_uploader_url ->
                withCredentials([usernameColonPassword(credentialsId: 'aptly-uploader', variable: 'USERPASS')]) {
                    sh """
                        for deb in postgresql-argm*.deb; do
                            # \$ for substitution to perform on Bash side, not in Groovy
                            curl --max-redirs 0 -f -u "${USERPASS}" "${aptly_uploader_url}" -F "my_file=@\${deb}" -F "name=\${deb}"
                        done
                    """
                }
            }
        }
        stage ('Cleanup') {
            cleanWs();
        }
    }
}
