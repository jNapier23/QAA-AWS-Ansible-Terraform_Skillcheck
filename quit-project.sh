#!/bin/bash

#Script to destroy terraform creations and shutdown Controller instance

echo Proceeding will destroy all instances and networks created by Terraform, and will stop the current instance.
echo Do you wish to continue? y / n
read answer

if [ "$answer" = "y" ]
then
    terraform destroy

    echo Did terraform destroy complete successfully? y / n
    read answer2

    if [ "$answer2" = "y" ]
    then
        sudo shutdown -h now
    else
        echo Please run the script again and be sure to enter the IAM credentials correctly before continuing
    fi
else
    echo Feel free to continue using the instances. When you are finished, run this script again.
fi
