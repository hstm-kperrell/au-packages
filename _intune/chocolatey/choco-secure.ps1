choco config set centralManagementClientCommunicationSaltAdditivePassword '/z^#;[F^N{Gf6&Fl4_k3(G;%^oIo+E&*'
choco config set centralManagementServerCommunicationSaltAdditivePassword 'vnG_onB-4%0n):X!]z=q;n.*}DH^N#./'
choco source add -n "'ChocolateyInternal'" -s "'https://chocolatey.healthstream.com:8443/repository/ChocolateyInternal/'" --user='chocouser' --password='o%*x!Pd-*-UH[$=I)>Ya-iPRy}A)A}Y{' --allow-self-service
Restart-Service chocolatey-agent