#todo: better clone the repo here
MANTA_BASE_DIR="/home/georgi/Desktop/workspace/Manta-Network/Manta/"
MANTA_CALAMARI_SUBDIR="${MANTA_BASE_DIR}runtime/calamari/src/"

MANTA_PC_LAUNCH_DIR="/home/georgi/Desktop/workspace/Manta-Network/manta-pc-launch/"
MANTA_PC_LAUNCH_DB_DIR="${MANTA_PC_LAUNCH_DIR}~"

DEEP_MANTA_DIR="/home/georgi/Desktop/workspace/Manta-Network/Deep-Manta/"
INJECT_KEY_SCRIPT="/inject_keys.sh"

BUILD_CALAMARI="cargo build --release --features=calamari"

#npm install pm2@latest -g

cd $MANTA_CALAMARI_SUBDIR
sed -i "/spec_version:/c\spec_version: 1," ./lib.rs
cd $MANTA_BASE_DIR
$BUILD_CALAMARI

cd $MANTA_PC_LAUNCH_DIR
rm -r $MANTA_PC_LAUNCH_DB_DIR
pm2 start dist/cli.js --name manta-pc-launch-runtime-upgrade-test --no-autorestart -- calamari-testnet-local.json

sleep 30s

cd $DEEP_MANTA_DIR
rm -f $INJECT_KEY_SCRIPT
python3 insert-script-gen.py 5 calamari_testnet 9971 > $INJECT_KEY_SCRIPT
chmod 777 $INJECT_KEY_SCRIPT
.$INJECT_KEY_SCRIPT

cd $MANTA_CALAMARI_SUBDIR
sed -i "/spec_version:/c\spec_version: 2," ./lib.rs
cd $MANTA_BASE_DIR
cargo build --release -p calamari-runtime

#pm2 stop manta-pc-launch-runtime-upgrade-test