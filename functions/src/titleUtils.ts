/**
 * Object -> Map<string, string>
 * @param {object} obj - TITLE object.
 * @return {Map<string, string>} The Map.
 */
export function objectToMap(
    obj?: {[key: string]: string}
): Map<string, string> {
  if (!obj) {
    return new Map();
  }
  return new Map(Object.entries(obj));
}

/**
 * 称号の差分を判定
 * @param {Map<string, string>} titleData 現在のタイトル
 * @param {object} updateMap 更新後のタイトル
 * @return {boolean} 差分があればtrue
 */
export function isTitleChanged(
    titleData: Map<string, string>,
    updateMap: {[key: string]: string | undefined}
): boolean {
  for (const [key, value] of Object.entries(updateMap)) {
    if (titleData.get(key) !== value) {
      return true;
    }
  }
  return false;
}
