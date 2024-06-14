const fs = require("fs");
const path = require("path");
const express = require("express");
const bodyParser = require("body-parser");


const port = process.env.PORT || 8080;
const url = process.env.URL || "localhost";

const app = express();
const urlencodedParser = bodyParser.urlencoded({ extended: false });

app.use(express.static(path.join(__dirname, "src")));
app.use("/src", express.static(path.join(__dirname, "src")));

// the below code is duplicate but I keep it for now
// it may be used for CORS
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "src", "index.html"));
});

app.post("/submit_email", urlencodedParser, function (req, res) {
  email_address = req.body.email_address;
  data = `${email_address}\n`;
  fs.appendFile("emails.csv", data, (err) => {
    if (err) {
      response = {
        status: false,
      };
      console.log(response);
      res.status(500).end(JSON.stringify(response));
    }
    response = {
      status: true,
    };
    console.log(response);
    console.log(`${email_address} appended to file`);
    res.status(200).end(JSON.stringify(response));
  });
});

app.listen(port, url, () => {
  console.log(`${url}:${port}`);
});
