#/bin/bash
# purpose : Kill a PID with a specific signal

if [ $# -lt 2 ]
then
        echo "Usage : $0 Signalnumber PID"
        echo ""
        echo "      SignalNumber:"
        echo "      1 = SIGHUP"
        echo "      2 = SIGINT"
        echo "      3 = SIGQUIT"
        echo "      9 = SIGKILL" 
        exit
fi

case "$1" in

1)  echo "Sending SIGHUP signal"
    kill -SIGHUP $2
    ;;
2)  echo  "Sending SIGINT signal"
    kill -SIGINT $2
    ;;
3)  echo  "Sending SIGQUIT signal"
    kill -SIGQUIT $2
    ;;
9) echo  "Sending SIGKILL signal"
   kill -SIGKILL $2
   ;;
*) echo "Signal number $1 is not processed"
   ;;
esac