import sys
sys.setrecursionlimit(10**6)
class Parser:
    def __init__(self, S):
        self.s = ""
        j = 0
        #string blank skip ex) x = " y z "
        flag = 1
        #list \n skip ex) x = [ 1,
        #                       2 ]
        flag3 = 1
        #comment skip ex) //comment sentence
        flag2 = 1
        while j < len(S):
            if S[j:j+2] == "//":
                flag2 *= -1
                j += 2
                continue
            if flag2 < 0 and S[j] == "\n":
                flag2 *= -1
                j += 1
                continue
            if flag2 > 0:
                if S[j] in { '[' , "]"}:
                   flag3 *= -1
                   self.s += S[j]
                   j += 1
                   continue
                if flag < 0 and S[j] == "\n":
                       raise ValueError("You forgot to write escape!")
                if flag3 < 0 and S[j] == "\n":
                   j += 1
                   continue
                if S[j] in { '"' , "'"}:
                   flag *= -1
                   self.s += S[j]
                   j += 1
                   continue
                if S[j] == " " and flag == 1:
                   j += 1
                   continue
                if S[j:j+2] == "\\\n":
                   j += 2
                   continue
                self.s += S[j]
            j += 1
    def scan(self, i, end):
        key = ""
        value = ""
        flag = 1
        tmp = {}
        while i < len(self.s) - 1:
            i += 1
            if self.s[i] in { '"' , "'"}:
                flag *= -1
            if self.s[i] == "{":
                value, i = self.scan(i, "}")
                tmp[key] = value
                key = ""
                continue
            elif self.s[i] == "=" and flag == 1:
                value, i = self.scan(i, "\n")
                tmp[key] = value
                key = ""
                continue
            elif self.s[i] == end:
                return (tmp if len(tmp.keys()) else key, i)
            if self.s[i] == "\n":
                continue
            key += self.s[i]
        return (tmp if len(tmp.keys()) else key, i)
