perform-orion-subscription

This simple bash script allows to perform a subscription to the FIWARE Orion Context Broker secured by a FIWARE Identity Manager (IdM).

To use it:
1. set all the variable at the beginning of the script  
    * (if the genericId is set to true the "entityTypeToBeSubscribed" parameter can be left empty)
    * You can use the "throttling" parameter to make requests with or without the throttling
2. chmod +x makeSubscription.sh
3. run the script with ./makeSubscription.sh

