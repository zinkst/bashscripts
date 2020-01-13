# .functions

function sso { sshpass -p "$SSO_PWD" ssh -o StrictHostkeyChecking=no -l zinks "$1"; }
function sshcpi { sshpass -p "$SSO_PWD" ssh-copy-id zinks@"$1"; }
function initBcli { cat ~/Documents/workdata/BlueMix/bin/init_boshcli.sh | ssh $1 'bash -';}
function flyrtp { fly -t rtp login --team-name bluemix-fabric; }
function flyds { fly -t ds login --team-name bluemix-fabric --insecure; }
function flysl { fly -t sl login --team-name bedrock --insecure; }
function cdb { cd  ~/Documents/workdata/BlueMix/${1}; source ~/Documents/workdata/BlueMix/bin/bm_profile.sh;}
function cdghe { cd ~/Documents/workdata/BlueMix/gits/GHE/${1}; }
function cdjml { cd ~/Documents/workdata/BlueMix/work/jml-work/${1}; }
#function cdwdc { pushd  ~/Documents/workdata/BlueMix/Deployer/Wdc_new/work/; }
function cdmrr { cd ~/Documents/workdata/BlueMix/gits/GHE/bedrock/mrr-release/${1}; }
function cdbed { cd ~/Documents/workdata/BlueMix/gits/GHE/bedrock/${1}; }
function cdelk { cd ~/Documents/workdata/BlueMix/gits/GHE/bedrock/elk-adapter-release/${1}; }
function cdela { cd ~/Documents/workdata/BlueMix/gits/GHE/bedrock/elk-adapter-release/src/github.ibm.com/bedrock/elk-adapter-acceptance-tests/${1}; }
function cdev { cd ~/Documents/workdata/BlueMix/gits/GHE/bedrock/elk-adapter-release/src/github.ibm.com/bedrock/event-forwarder/${1}; }
function cdbsl { cd ~/Documents/workdata/BlueMix/gits/GHE/bedrock/bosh-lite-state/environments/softlayer/director/${1}; }
function b2 { source b2_setup_lite.sh; }
function bsl { source bsl_setup_lite.sh; }
