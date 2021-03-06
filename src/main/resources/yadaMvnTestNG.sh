#!/bin/bash

usage() {
printf "Usage: $0 [-T [surefire|failsafe|skip|<empty string>]] [-x surefire|failsafe|jetty|all] [-p test] [-Xtdsi] \n \
  -T  Execute either surefire (api) or failsafe (http) testing. Omit argument or set \n \
      to 'skip' to suppress both. Failsafe suppression will also suppress jetty launch. \n \
      Default (option -T omitted altogether) is to execute both. \n \
  -x  debug surefire or failsafe test, or jetty and failsafe execution. \n \
      Leave argument empty to debug surefire, failsafe, and jetty. \n \
      'jetty' implies 'failsafe' because maven won't wait for tests to execute long enough to \n \
      launch the jetty debugger. \n \
  -p  choose the profile. 'test' is the currently preferred test profile.  \n \
  -X  show maven debug output. \n \
  -t  use the 'tmp_toggle' file to cherry pick tests. Default is all tests. \n \
  -d  show java debug log output. Default log level is 'info'. \n \
  -s  deloy snapshot to maven central.  Implies '-T skip' \n \
  -i  print command to test webapp interactively. Combine with  '-x failsafe' to debug as well \n \
  -r  local maven repository \n \
  -?  show this help \n\n \

  NOTES:
  The YADA_HOME and YADA_LIB environment variables must be set.
" 1>&2; exit 1; }

# this option not working currently--has something to do with forking
# -i  test the webapp interactively. Combine with  '-x failsafe' to debug as well \n \

SUSPEND=n
MAVEN_DEBUG=
TOGGLE_TESTS=
LOG_LEVEL="-Dlog.level=info"
SUREFIRE_X=0
FAILSAFE_X=0
JETTY_X=0
DEBUG=
PROFILE=
YADA_PROPS="${YADA_PROPS}"
SKIP_SUREFIRE=
SKIP_FAILSAFE=
SKIP_JETTY_LAUNCH=
DEPLOY_SNAPSHOT=0
INTERACTIVE=0
MVN_REPO=""
# CONTAINER_OPT="-Dcargo.tomcat.connector.relaxedQueryChars='^&#96;{}[]|&quot;&lt;&gt;'"

OPTERR=0
while getopts "Xtdisx:p:T:r:" opt; do
  case ${opt} in
    r )
      MVN_REPO="-Dmaven.repo.local=$OPTARG"
      ;;
    i )
      INTERACTIVE=1
      ;;
    s )
      DEPLOY_SNAPSHOT=1
      SKIP_SUREFIRE=-Dsurefire.skip=true
      SKIP_FAILSAFE="-Dskip.tests=true -Dskip.jetty.launch=true"
      ;;
    T )
      if [ "surefire" == "$OPTARG" ]
      then
        SKIP_SUREFIRE=
        SKIP_FAILSAFE="-Dskip.tests=true -Dskip.jetty.launch=true"
      elif [ "failsafe" == "$OPTARG" ]
      then
        SKIP_SUREFIRE=-Dsurefire.skip=true
        SKIP_FAILSAFE=
      elif [ -z "$OPTARG" ] || [ "skip" == "$OPTARG" ]
      then
        SKIP_SUREFIRE=-Dsurefire.skip=true
        SKIP_FAILSAFE="-Dskip.tests=true -Dskip.jetty.launch=true"
      fi
      ;;
    x )
      SUSPEND=y
      if [[ "$OPTARG" =~ .*surefire.* ]]
      then
        SUREFIRE_X=1
      fi
      if [[ "$OPTARG" =~ .*failsafe.* ]]
      then
        FAILSAFE_X=1
      fi
      if [[ "$OPTARG" =~ .*jetty.* ]]
      then
        JETTY_X=1
        FAILSAFE_X=1
      fi
      if [ "all" = "$OPTARG" ] || [ -z "$OPTARG" ]
      then
        SUREFIRE_X=1
        FAILSAFE_X=1
        JETTY_X=1
      fi
      ;;
    X )
      MAVEN_DEBUG=-X
      ;;
    t )
      TOGGLE_TESTS=-Dtest.toggle=/conf/tmp_TestNG_toggle.properties
      ;;
    d )
      LOG_LEVEL="-Dlog.level=debug"
      ;;
    p )
      PROFILE="$OPTARG"
      ;;
    ? ) usage
      ;;
  esac
done


CMD=
MAVEN=mvn
WORKSPACE=/Users/dvaron/Documents/work
YADA_SRCDIR=$WORKSPACE/YADA
# CONTAINER=tomcat
# TOMCAT_VERSION=8x
# YADA_LOCAL_TOMCAT_HOME=-DYADA.local.tomcat.home=$WORKSPACE/containers/$CONTAINER$TOMCAT_VERSION/
MVN_DEPLOYMENT_GOAL=-Ddeployment.goal=start
LOG=$YADA_SRCDIR/src/main/resources/testng.log
LOG_STDOUT=-Dlog.stdout=true
SKIP_LICENSE=-Dlicense.skip=true
SKIP_DB_LOAD=-Dskip.db.load=true
SKIP_JAVADOC=-Dmaven.javadoc.skip=true
SKIP_SOURCE=-Dmaven.source.skip=true
# following prop required to enable HttpURLConnection to include Origin header
# it is ignored by default
CORS_HEADERS=-Dsun.net.http.allowRestrictedHeaders=true
#TOGGLE_TESTS=-Dtest.toggle=/conf/tmp_TestNG_toggle.properties

COMMON_VARS="\
$LOG_STDOUT \
$MVN_DEPLOYMENT_GOAL \
$SKIP_SUREFIRE \
$SKIP_FAILSAFE \
$SKIP_LICENSE \
$SKIP_DB_LOAD \
$SKIP_JETTY_LAUNCH \
$SKIP_JAVADOC \
$SKIP_SOURCE \
$TOGGLE_TESTS \
$LOG_LEVEL \
$MVN_REPO \
$CORS_HEADERS \
$YADA_PROPS"

if [ -f "$LOG" ]
then
  rm $LOG
fi
cd $YADA_SRCDIR


if [ "y" == "$SUSPEND" ]
then
  if [ 1 -eq "${JETTY_X}" ]
  then
    # the (possibly) easiest way to put jetty into debug mode is with a dedicated profile.
    # passing debug args on the maven command line is a pain, and didn't work
    # see the jettyDebug profile in yada-assembly.pom for details
    PROFILE=${PROFILE},jettyDebug
    FAILSAFE_DEBUG="-Dmaven.failsafe.debug"
  fi
  SUREFIRE_DEBUG="-Dmaven.surefire.debug"
  FAILSAFE_DEBUG="-Dmaven.failsafe.debug"
  if [ 1 -eq "${SUREFIRE_X}" ]
  then
      DEBUG="${DEBUG} ${SUREFIRE_DEBUG}"
  elif [ 1 -eq "${FAILSAFE_X}" ]
  then
      DEBUG="${DEBUG} ${FAILSAFE_DEBUG}"
  fi
  DEBUG="${DEBUG} -DYADA_LIB=${YADA_LIB}"
fi

if [ 1 -eq "$DEPLOY_SNAPSHOT" ]
then
  CMD="$MAVEN ${SKIP_FAILSAFE} ${SKIP_SUREFIRE} ${SKIP_LICENSE} -DskipTests=true clean deploy"
elif [ 1 -eq "$INTERACTIVE" ]
then
  if [ 1 -eq "$FAILSAFE_X" ]
  then
    DEBUG="'-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005 -Xnoagent -Djava.compiler=NONE'"
  fi
  # GOAL=org.codehaus.cargo:cargo-maven2-plugin:run
  # CONTAINER_ID=-Dcargo.maven.containerId=tomcat8x
  # CONTAINER_URL=-Dcargo.maven.containerUrl=https://repo.maven.apache.org/maven2/org/apache/tomcat/tomcat/8.5.49/tomcat-8.5.49.zip
  CMD="java ${YADA_PROPS} -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5006 -Xnoagent -Djava.compiler=NONE -jar yada-api-${YADA_VERSION}.jar"
else
  CMD="$MAVEN $MAVEN_DEBUG clean verify -P${PROFILE} $DEBUG -Dsuspend.debugger=$SUSPEND $COMMON_VARS"
fi
echo $CMD
if [ 1 -eq "$INTERACTIVE" ]
then
  exit 0
fi
exec $CMD > >(tee -i $LOG)
echo "[$$] ${CMD}"

perl -e 'while (<>) {chomp;if (/^Tests run.+Time/) {print $_."\n";}}' < $LOG
