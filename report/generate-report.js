const fs = require('fs');
const path = require('path');
const xml2js = require('xml2js');
const ejs = require('ejs');

// Obter a plataforma da linha de comando
const platform = process.argv[2];
const xmlPath = path.join(__dirname, '..', `report-${platform}.xml`);
const htmlPath = path.join(__dirname, '..', 'html-report', `report-${platform}.html`);
const templatePath = path.join(__dirname, 'report-template.ejs');
const screenshotsPath = path.join(__dirname, '..', 'screenshots');
const imagePath = path.join(__dirname, 'logo.png');

// Verificar se o arquivo XML existe
if (!fs.existsSync(xmlPath)) {
  console.log(`Nenhum relatório encontrado para a plataforma especificada: ${platform}`);
  process.exit(1);
}

// Ler o arquivo XML
const xmlData = fs.readFileSync(xmlPath, 'utf-8');

// Converter XML para JSON
const parser = new xml2js.Parser();
parser.parseString(xmlData, (err, result) => {
  if (err) throw err;

  // Ler e codificar a imagem
  const imageBase64 = fs.readFileSync(imagePath, 'base64');

  // Renderizar HTML usando EJS
  ejs.renderFile(templatePath, { testsuites: result.testsuites, screenshotsPath, imageBase64, fs, path }, (err, htmlContent) => {
    if (err) throw err;

    // Escrever o HTML no arquivo
    fs.writeFileSync(htmlPath, htmlContent, 'utf-8');
    console.log(`HTML report generated at: ${htmlPath}`);
  });
});
