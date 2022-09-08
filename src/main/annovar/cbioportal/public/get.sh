url=`curl -X GET https://api.github.com/repos/cBioPortal/datahub/git/trees/master | jq -r '.tree[] | select(.path == "public") | .url'`
for studyid in `curl -X GET $url | jq -r '.tree[].path'`
do
    wget https://media.githubusercontent.com/media/cBioPortal/datahub/master/public/$studyid/data_mutations_extended.txt -O ${studyid}_mutations.txt
done

