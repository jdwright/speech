using ZipFile
function readt()
    r = ZipFile.Reader("/opt/local/corpora/timit_labels.zip");
    for f in r.files
        println("Filename: $(f.name)")
        # write(stdout, read(f, String));
        m = match(r"(\w+)\.(\w+)$", f.name)
        print(m)
    end
    close(r)
end

struct Source
    uid::String
    # btime::Float64
    # etime::Float64
    # btime::Int
    # etime::Int
    range::UnitRange
end

struct Ann
    source::Source
    label::String
end

function test2()
    set = Set()
    dn = "/pubs1993/S/1W/package/timit"
    for (root, dirs, files) in walkdir(dn)
        for file in files
            path = joinpath(root, file)
            a, b = split(path, '.')
            if(b == "wav")
            #    push!(set, path)
                aa = read("$a.phn", String) |> x -> split(x, "\n")
                for x in aa
                    if length(x) > 0
                        bb = split(x, " ")
                        push!(
                            set,
                            Pair(
                                Source(
                                    a,
                                    parse(Float64, bb[1])/16000,
                                    parse(Float64, bb[2])/16000
                                ),
                                bb[3]
                            )
                        )
                    end
                end
            end
        end
    end
    set
end

function test3()
    set = test2()
    set = filter( x -> x.label == "s", set)
    a = map( x -> x.source.etime - x.source.btime, collect(set))
    summarystats(a)
end

function test4()
    fn = "timit/test/dr1/faks0/sx133.wav"
end

struct UttFn
    set::String
    dialect::String
    speaker::String
    sentence::String
    wavfn::String
    txtfn::String
    wrdfn::String
    phnfn::String
end

struct Utt
    set::String
    dialect::String
    speaker::String
    sentence::String
    wavfn::String
    txt::Vector{Ann}
    wrd::Vector{Ann}
    phn::Vector{Ann}
end

function readlabelfile(fn::String, docid::String)
    a = readlines(fn)
    a = map( x -> split(x, " ", limit=3), a )
    a = map( x -> Ann(
        Source(
            docid,
            parse(Int, x[1]):parse(Int, x[2])
        ),
        x[3]
    ), a)
end

function readtimit(base::String)
    a = Utt[]
    for (root, dns, fns) in walkdir(base)
        for fn in fns
            rfn = joinpath(root, fn)
            m = match(r"(\w+)/(\w+)/(\w+)/(\w+)\.wav$", rfn)
            if m != nothing
                push!(a, Utt(
                    m.captures[1],
                    m.captures[2],
                    m.captures[3],
                    m.captures[4],
                    rfn,
                    readlabelfile(replace(rfn, r"wav$" => "txt"), rfn),
                    readlabelfile(replace(rfn, r"wav$" => "wrd"), rfn),
                    readlabelfile(replace(rfn, r"wav$" => "phn"), rfn)
                ))
            end
        end
    end
    a
end

function allphn(all::Vector{Utt})
    reduce(vcat, map( x -> x.phn, all ))
end
function selectphn(all::Vector{Utt}, phn::String)
    allphn(all) |> x -> filter( x -> x.label == phn, x )
end
function mapsource(f::Function, sources::Vector{Source})
    # map( x -> f(wavread(x.uid)[1]), sources)
    map( x -> f(x), sources)
end
function mapsource(f::Function, sources::Vector{Ann})
    mapsource( f, map( x -> x.source, sources) )
end
function cacheread(cache, x)
    # get!(cache, x.uid, wavread(x.uid))
    if !haskey(cache, x.uid)
        cache[x.uid] = wavread(x.uid)[1]
    end
    cache[x.uid]
end
function tryf(cache, utt)
    sgo = sg(cache[utt.wavfn], .005, .001)
    sources = collect(utt.phn)
    sourcesi = 1
    s = sources[sourcesi].source
    # collect(Iterators.product( collect(sgo.t), sources ))
    [ (last(x), y.label) for x in zip(sgo.t, eachcol(sgo.s)), y in sources if first(first(x)) >= first(y.source.range) && last(first(x)) <= last(y.source.range) ]
end
