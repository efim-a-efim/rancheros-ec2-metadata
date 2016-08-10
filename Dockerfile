FROM alpine:latest
RUN apk -Uuv add bash jq ca-certificates groff less python py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*

ADD ./entry.sh /entry.sh
ADD ./ec2-metadata /lib/ec2-metadata
RUN chmod +x /*.sh

ENTRYPOINT [ "/entry.sh" ]
CMD ['-m', '-t', 'com.']
