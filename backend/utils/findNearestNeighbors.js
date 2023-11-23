let titles;
async function predictRatings(data, products, name) {
  titles = [...new Set(products.map((item) => item._id.toString()))];
  let newUser = [];
  let others = [];
  console.log(`data length:${data.length}`);
  data.map((item) => {
    console.log(item);
    if (item.name === name) {
      newUser.push(item);
    } else others.push(item);
  });

  return await findNearestNeighbors(newUser[0], others);
}

async function findNearestNeighbors(newUser, others, k = 5) {
  const similarityScores = [];
  let tempo = [];
  for (let i = 0; i < others.length; i++) {
    let other = others[i];
    let similarity = euclideanDistance(newUser, other);
    tempo[other.name] = similarity;
  }
  const names = getObjectName(tempo);
  for (let x of names) {
    similarityScores.push({ name: x, similarity: tempo[x] });
  }
  similarityScores.sort(compareSimilarity);
  function compareSimilarity(a, b) {
    let score1 = a.similarity;
    let score2 = b.similarity;
    return score2 - score1;
  }
  if (similarityScores.length < k) k = similarityScores.length;
  // for (let i = 0; i < k; i++) {
  //   console.log(`${others[i].name}: ${similarityScores[i].similarity}`);
  // }
  return others[0].name;
}

function getObjectLength(obj) {
  return Object.keys(obj).length;
}

function getObjectName(obj) {
  let name = Object.keys(obj);
  return name;
}

function euclideanDistance(ratings1, ratings2) {
  console.log(ratings1, ratings2);
  let sumSquares = 0;

  for (let i = 0; i < titles.length; i++) {
    let title = titles[i];
    let rating1 = ratings1[title];
    let rating2 = ratings2[title];

    if (rating1 != (null && undefined) && rating2 != (null && undefined)) {
      let diff = rating1 - rating2;
      sumSquares += diff * diff;
    }
  }
  let d = Math.sqrt(sumSquares);
  let similarity = 1 / (1 + d);
  return similarity;
}

module.exports = {
  findNearestNeighbors,
  getObjectLength,
  getObjectName,
  predictRatings,
};
