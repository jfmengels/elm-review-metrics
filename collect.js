const path = require('node:path');
const {spawn} = require('node:child_process')

const folders = process.argv.slice(2);

Promise.all(
    folders.map(
        f =>
            new Promise((resolve) => {
                let data = '';
                const p = spawn(
                    'elm-review',
                    [ '--extract'
                    , '--report=json'
                    , '--config'
                    , '/home/jeroen/dev/elm-review-metrics/preview/'
                    , '--elmjson'
                    , path.resolve(f, 'elm.json')
                    ],
                );
                p.stdout.on('data', (newData) => {
                  data += newData;
                });
                p.stderr.on('data', (err) => {
                  console.error("ERROR", f, err)
                });
                p.on('close', () => {
                    console.log('DONE', f);
                    resolve(data)
                });
            })
            .then(JSON.parse)
    )
).then(results => {
    console.log(
        results.reduce(
            (a, b) => {
                try {
                    b = b.extracts.CountAlways;
                } catch (e) {
                    console.error('ERROR', b, e)
                }
                return { noArgs: a.noArgs + b.noArgs
                , singleArg: a.singleArg + b.singleArg
                , bothArgs: a.bothArgs + b.bothArgs
                }
            },
            { noArgs: 0
            , singleArg: 0
            , bothArgs: 0
            }
        )
    );
})