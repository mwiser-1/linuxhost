.PHONY: changelog release

TMP:=.test.zip
BUCKET:=observeinc/terraform-modules

changelog:
	git-chglog -o CHANGELOG.md --next-tag `semtag final -s minor -o`

release:
	semtag final -s minor

changelog-patch:
	git-chglog -o CHANGELOG.md --next-tag `semtag final -s patch -o`

release-patch:
	semtag final -s patch

s3:
	zip -Xr $(TMP) *
	aws s3 cp $(TMP) s3://$(BUCKET)/$(notdir $(shell pwd))-$(shell semtag getlast).zip
	rm $(TMP)

outputs:
	grep "resource \"observe_dataset\"" *.tf | cut -d' ' -f3 | awk '{gsub(/"/, "", $$0); print "output \""$$0"\" {\n  value = observe_dataset."$$0"\n}\n"}' > outputs.tf
	grep "resource \"observe_dataset\"" *.tf | cut -d' ' -f3 | awk '{gsub(/"/, "", $$0); print "output \""$$0"\" {\n  value = lookup(data.observe_dataset.aws, \""$$0"\", null)\n}\n"}' > readonly/outputs.tf
