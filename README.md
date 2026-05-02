# README file for deployment on a new server

When a new server is created, perform below steps to get the lab running:

- Add / Update the `SERVER_IP` and `SSH_KEY` under Repository Settings -> Secrets and Variables -> Actions -> Repository Secrets.
- Run the `Docker Deploy pipeline` on GitHub.
- Verify by opening `https://<IP_ADDRESS>.nip.io/` on your browser.
