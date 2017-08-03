# Nice Token
niceToken.sh is a script for managing aws session tokens when using IAM roles in conjunction with MFA.

In short, the Amazon CLI provides a token for one hour at most when assuming an IAM role with MFA, which is inimical to most development workflows.

However, when getting a session token using MFA, that token is valid for 12 hours by default, and can be used to assume a role without the need for an MFA re-entry. This script gets a session token using the user’s main identity and then uses that token to assume a role and renew it every hour.

## Setup and usage.

### Dependencies:
JQ is required. In windows make sure it is on the command line. The easiest way to do that is using choco.

AWS CLI is also required.

### Setup:
Place the shell script in a directory of choice and add to .bashrc if you so desire. 

This script relies on a few environment variables:
* `$AWS_PROFILE` and `$AWS_DEFAULT_PROFILE`  note that PROFILE is used by AWS SDK and DEFAULT_PROFILE is used by AWS CLI. These should match. This name is arbitrary but it is the profile you will be using in your apps.
* `$MFA_DEVICE` the Amazon ARN of your MFA device. Visible on the IAM page for your user.
* `$MFA_ASSUME_ROLE` the Amazon ARN of the role you would like to assume. Visible on the IAM page for the role. 

The script also relies on a configured AWS profile called `nice-identity-long-term`. Make sure this is in your credentials file. This is the profile your existing keys will go under. Also configure an empty profile to match whatever you specified for `AWS_PROFILE`.

To run, just execute in a terminal session as such:
`./niceToken.sh 123456` where 123456 is the MFA code given by your device. 

Note that you can append & to the command to run it in the background. 
