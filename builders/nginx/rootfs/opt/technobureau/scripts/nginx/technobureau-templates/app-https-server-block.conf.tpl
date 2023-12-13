{{external_configuration}}

server {
    # Port to listen on, can also be set in IP:PORT format
    {{https_listen_configuration}}

    root {{document_root}};

    {{server_name_configuration}}

    ssl_certificate      technobureau/certs/server.crt;
    ssl_certificate_key  technobureau/certs/server.key;

    {{acl_configuration}}

    {{additional_configuration}}

    include  "/opt/technobureau/nginx/conf/technobureau/*.conf";
}
