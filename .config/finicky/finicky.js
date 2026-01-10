export default {
  defaultBrowser: "Brave Browser",
  handlers: [
    {
      // Open these urls in Brave Beta
      match: [
        "*employmenthero*",
        "*mygithubusername-companyxyz*"
      ],
      browser: "Brave Browser Beta"
    }
  ]
}
