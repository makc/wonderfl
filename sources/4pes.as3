package  {
	/**
	 * ...
	 * @author milkmidi
		http://milkmidi.blogspot.com
	 */	
	import flash.display.Sprite;	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.GlowFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.*;
	import flash.utils.setTimeout;
	[SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#0")]
	public class Elect extends Sprite {			
		private const data:String = "iVBORw0KGgoAAAANSUhEUgAAAT8AAADACAYAAAByFWTTAAAbAElEQVR4nO2d63XjOrKFd8+a/3QG1I1AzoA6Edg3AnkicE8E8kTgngjkE4F9IpBOBHJHQHUE6o7A8wNEE6KBAsAnKO1vLSzZfIAgSG5UFUDwCwiJJwNwC2BlWWdbZuNYpSbvVfoRXyxCwvkydQFI8uQAFlCidlulxQjH/QklgntQEMkAUPxIkzvUVt0tgJtJS3NOUxD/mrQ0hJDZswSwBXAC8DGjdKrKfdd/lRBCLpUlgGcAJaYXsb6E8BXAGiomSQghv8kBPAI4YHqxGjppISSEXDE5lHs4tSBNkUpQBIkFdnhcNjmAJwAPA+W/R90J8V79HcINVGdKkxVUT/Kic8k+c4Sqiz8HyJvMEIrfZVIA+Argvoe8jlV6b/wOOexEjyM0h9asesr7CIogIRdHAWCHflzFZ6hOkZRYQsUsX0F3mBAC5d52Fb1UBU+iQPce6xIcKkPILHlE+/F5cxQ8F3qsYlsRfAWHyBAyC9pae3pg8CUIno0MqkFoYw2eQCuQkKRpY+1dY4yrQLv4IK1AQhKjjbV3jaLXpEC8S0wrkJBEiLX2KHqfWSK+8aAVSMiExFotz+ADK3GHuJjgAaxPQkYlQ5ylcoByjUkYG4Rb0ydcbicRIUmRIXwCghPUg0ziiYmjUgAJGZgc4cJ3AB/IPgiNqZ7AWCohg7BEuCu2BWNRfRLT6FAACemRGOF7nKiMU7LEOFZuaAcTQw2E9MAaYcJX4jrdXFOQxhCdNcIEcAt2MhHSmtAH7VrjezZLbAzBKRAeB6QAEhLJHcKEb4frjO+5XNCxXM4lwsYEciwgIRGExvhepyrgxEixt8OI5QjtCLnW60RIFKHCt52qgBMT0ukwpqUVKoDXer0ICSJDmCt1rQ9SiPB9YPyJBzKENVjrkctFyCwIfXODwpdmHYVa7MUEZSMkaSh8bmKE7wPKep6CEAHkq3CEGIQ83Nc6hZJUNyXck5JOJTAhAsgeYEKg3sjwCd+1PiyS8Ok6WTrWT/mmy9pRpmZjRsjVksNvJZQIF74M6qHaQc3dl/dc3jEJET5NadlmanEJEUDOCE2ulh388aEYAXu27L/B/KxGSfhs7r9r+6nxhTNOmN+1IaQzIe5uEZmny4osMR8rQxKMrWMf19swKZyzryNraguVkFEJCYqvW+TrE9Md0u5pbCN8gLKebPs8D1nYQELGALa51oTMEp81sGuZr0/8TCFJzd0q4C/3AcqNt1nEO8v25eClDsN3bpwAgVwFGwz3IISKnz5OSnP/rRFf/leoc8jhrtdURMV33ds2eITMAtewDDNtOuQfIx6mdWSzpMbG5bp2TesxT8KDz+JPqTEipFdsrlnTreuCJHA+kXjF9FbSFv2LX0odCr7Gj+4vuUgK+B/Urp0RkqBuEPbu6QbTxgOLqgyh38zwpdO4xfeygVze7XRFI2QYfFbfpodj2PLdGeszhFlXJ6QxTCSDKscz4j4mnrL4Af57gdbfhHyZugAXRgFgL6w/ArgF8KvjcT4sy/YA/mgsywG8VceUuAXwvWOZfBQAVgBuPOU5AnivtlsAuK/+9vENwL+7FHAAllDn4uIFwL/GKQohw+Jr6YuejuOz/Jr4pmIvMYwLnENZum2tOW2VLqE6CVyTG3wg3XGNzbdxaP2Ri6PAeDEel4C5yhUSV+vDHdfkUA996Gc4pWR7za2o8t9Vad1j2fsmh1wPfd4XhEzCmPEd1zFMcsiWksvK6kKG/kTPTKmNVYxlA1p/5EIZ0+qDcBxACZDvYWsKS9FDmdboX/SaaYd03VsJ36tvtP7IbBnT6oNwnFgB2qCfWJ9P/PtOmx7KPDa0/sjFMbbVB8/xQpI00DmrzsmVmpZX6DctTlCNxKbKxxXHCx3313Wg+NjQ+iMXhy+uNkSL3lb0Dvjs4maoe1LLwHxKKCF7RNjkDevI89OxQ185UpjNJQbJ+ktxnCIhTnzvqQ7VmseK3gmfBWiJuA6RPo4ZSwF/SCGFQdqh5LiccyFXjmtyzSGtPniO2UwbnLuYBfp7pcyVDuj33H0W01D1PASSmA/VWBLSO1vIAjAUIQLUjOtlGNbSM897iAHT0mQBuwGONxRSg0nXl8wGKYA95Li0UjiuLa63FrbvOw1phUnn0TznlJHuG7q+JHmmcnkBu+tqi7Fllu2kpHtkn6HEu2ikNZT16Hp4x3hwd45jpzSllY8t3NdgO2G5CAlCuoHHGoZxBxUPe8RnVzNH+Ji/A5SwxbirBc7f5hjroS3gPo+5QNeXzJoS07i8IYRafK/o/sZEBiWcQ1q6TVyxyzm5jHR9ySzxzdQ7phDY8HVspDKPX1ty2M9rTuP+pGtE15ckywbTu7wupLJ9QMXMphbnPrBZtlPXfQyPcF+jcsJyESKyQ5our88ivSSLYos0re5QfNeKkCSR4jVTzjoixfmGGn83FWvYz3M9ZaEike6jYsJyEWLFFW+ausWW3Ki5vQURgus6zGnIixT3m7rT7OL5x9QFmCHS9yek7zUMSQbgSVj/DcCPcYoyGj9gr+/VyOXognS/LMYqxLVC8YtnJaybSvykj/y8A/jPiGUZk71l2Q3m4zLuhXW+j04RMjpSZ8dmojKVQplSF4Il6jdIYmOSBdK6Dm2QQhWEJIUU75tCaKRew5R7dzPYG5It4jqNXJ07c0FquC4tTktmTIqDmzdCeVK1+kJmf94izBJ0dRrMpWdb8iRSvX4XAWN+cUhxmJ+YplNh5Vj+E8DfI5YjlCVUrMv3IfIHAF8D8ts7lt8Hl2ha9sK61UhluEoofnEshHVTdXasHMvfxixEBN/gFz5NF/FbBR5jan5OXYBrheLXH1OJn4v91AWwsEScKN3A/w7ydwBHy/K5WH4c7jIR/5y6ABfEFC24FBM6DnC8Nc4fyHcAf0XsH2rxmawCjrGHcpObx1pCieNcWUxdAEI0qQ1zcQ316DtYvoa7V/KA8N5ZqbyuVAbk65ofby5vSbjOfTdloQgxkcRviimicqE8fYmf1Jus0wlhvasZwj+PaSafuLq+ojcX8aD4keRJcVjCkGLsm6rfTKHv1IZ8j7eNBeea1GEOQ16kRoUMBDs85s/esbzr61E5gJeI7e8RJjT7FmV56JDvqsXxxuboWN4mRkoCofjNn6Nj+aJjvgvEP3wPAdvsYwsCJeQ+YXX1ms6h1/c4dQGuEYpfHCm2xK6HfjVmISpChOYX2g0L8uW9dyxftTgWIaSBFJeaikIoUz5Qvl3rYdsi35CYoqszpUs9jEGKseSLh5bf/JFeYVt1yLftoO2Qh3XfIt9Vh3zn4PqSkaH4XQZHx/JVhzzbuqchx9y3yDfkbQ9XvqsWxyMXDsXvMtg7lq8Gylci5Jg/0C7Ib8u7gBo+c4C7d7rNsQghBinG/AD3x3y6xrtixvnF1oXv28K2VFZleoYcJxsr5qc/2P7Y8RjSuaQeryRXQqo3aS6Ua90hX9ebE74UMsBa+uBSn6mvD5nnqOOZd/jcadPlw0mpNqqE/EYSv0LYbwxK2Mu17ZhvjIUVIzi+iWH7SK/o5w2PR9STr0qTsLY9FsWPJE/K4te0RHQqO+a7ceQrpdBp5H2zObdNO/Tzel+GOPd83fI4FL8JYIdHf0w9AHrvWL5Atw+pu/KV8L2RkUNZU31NA/YONUnqPYAvAP5A3FRbNu6gOkpCh8n8RLu3avIW+5Ae4Hx+/XGL7g9cF6SZm1doP6/d31APdqy4r3BeH3fVsnt0f/XuCCXKe6jz/tUxPxsruM/5BfU5vFdlaPvJgIWwjrM8k2SQXMDNhOXSuGY26RKMB9r1zB6gXPGyxb7NdKrKsEZ7Symv9g+Ny0k93U2XegN1vgfEhz8K4Ti7yLwIGQxJ/FK4UV3TRXWdGmmsntlmfT6ivcueQ12vV5zHFrcRebjKpvMo8FncY3uXU7+nCAEg36gpfCtWsla6xP3G6Jk9QNVvrOXkwlUXZUQeLov3JKyLvQ+k+Q0pfiQZCsgP8NRI4/K6Tuned89sCfXg32GYCUelughpCAq0t3hjzmcn5LOJyIeQQfEN+s2nK9pv+oz7LaEEoOk6thW7LbrF7WKxCcsJ9mEwOdrNMm1LMcNsyp7yIWRwUr9ZN7CXLSTuV8AeJ2uTtGvYJW7XFe36HqCEzVUOcxBzH2kbUcbUG1NCfiP1fKbgphRwl6/58C+hymyzkNqkHfqN2/XNHZTI7VC7pjn6Ez2dysDySNeK3+8gyeGyrPTDnwKu8r0iflIAKWmLKgWLVyLH53PWMdAt3Od3QvuhOiFW21rYP5V7iZDfSD2qqbTWfYmbzaLZIm683FjcQYn7DqqByo3lNpdWx0Bd7u7GyNtVn5KrvA4osyS8G2E/QiYhhywQU8W3TDboR+z6GFw8NGvYrTPdsVFY1pkNlW3dtnEMV4MniV9IB5Ot3Dqlbk2TK6Vriz80OdoH8Hfo1klxh+7DamzkVd4b1HW8hl+8M8jWXYjV5RLQUsjb5wX4xk6m2tiQK2eHbi3+GLge2Gbqa3CxOQNKHwO+M+PX1sl0QJjA3zn210LvqhMTqZNLuhekBkQaVpNK+ISQT7gshtRuXJtlVKL74OIM53G1JT4LUVvLZQ0lKKUj39ik3XaXyLnyf4ZqECTh84mfZAGXnjITkiQ+lyWleE0G9RAX6MeVMsfE6bxtArJuUU6f0LRJJ8hx2q7HdInfCe5OC9/9E1t3hIyK1HJvJyxXn+Q47zVtnvMd3FZVjPXS1cLTrrsrj8JSdp02HY6rRW4NJYI71BajhO9NktR60gk54xHyAzFHctQfCNJi8Qp3b+cWbqvKVge682GD8wdcqsuQpGNrLiF7hltwtvB3nPiEN/fUaxOXEMc2GoRMguuh1ykl1zeUHdyWje0cy2o/18PctIBMF/OEOibmcwO1yNgsu2bnhGsbl4Drcygc+5pph/O3WNpYaHR5yUVwgPsm3k5Yrra4RGwjrFvCbVU9G3lL4pML+etjwHGcpoVpE/APyI2Vzn8J98DjvsZv+lzevKfjEDIoPndtbrEbV/B/C/dD+wi3sGmrLIMsbjncomMKqMtqMq0l1zV5FM6v2StrdhIV6Pc6SvXQxxAhQkZBsiZsD1XqbHBe/h3q2VBcArer9pWETbJ2NtX+a0/+GptrasbJXAL5CrcwjhVnKxzHn+v9Qq4caahEOWG52pBDPYBFY9kOcqfAHdzupsuia1o6mbCdaXnZ8mu6vq7YXWasKzH+pAyuOjIbCkJmgyQKWhjmiB7IbFporhjnFu16bJtxNFf+a2MblwVqCrZNIA+W442Jz+qjy0tmSYn53dQZlKi8oraCtIW1xOdz2kGeKDWkx7a5z6ZRJlf+plvqshDN2GBelfcV6UzK4LP61u5dCUkXn/VXuHedBJu4fVTLCsc6fR6SFSc1Aq5UoraOXQLabEBsQpJqIwP4Y8PldEUjpDupWn8FlDibwzmk8WxSDNPlcn5AWW1bYb0v7TxlM13WdWO/DdJrYEx89UKrj8wan/U35g2e4fwtDdPC8A3kLeGOvT1D/mSjrw5CUuhwlJTFzoRWH7kKJOuvxLDj/h6hrKAc8uDrLgJUQu7YkB50qW4kAT1Ux8z7q6pR2SKdRpGQwfBZPpsBjlmgu9iFip9+WKV1rrJsqvWS5bmEEjndUTG3QeJNpMZANwiEXAw+C6fo6TgZuk/H5BKig3Aej8J+W7h7bHdGuW3W0CUO8N2BVh+5IiTLSAtLV5boZu3pYS3SmxeuB/cAt+ieIPcImxTGOWx7qJPUcDUCtPrIReOz/p7du/aSf4j4AXLvrWRVSg+2q8fW9bCvMX/3tknImMe5Dn4nRESyfkyRaMvWk/cO7k82NoUo1vLziV+BeuD0Ft0+hjRHMvit8rHeJSZkEiSX8gPqAWlr8eSevLfVdpL1lgds4xJALW627S/NiovFd91PYB2RCyeD3z3dOvf2I4mWftF/LWyjOxikoSsu8duiHtR8bZadRAG6u4QAGPZh8E0kAMgzpeiOF8mK3Dr2K1qW+ZIxZ4xxJbq75KoIcYNy595ufMKqBUqKP2n3y2WhLqEe2Gd0+9TlNeCL85Vg/ZErI8T9bRv/C7EyNsI262obU6AP1T50ZcOxWciuxoiQqyLE/W3jEu08eQLysIvC2GaN+b5CNiVr+K9t16FNhMwan/vb5iGRrDrJrS0xzKt210ZIo0Z3l1w9IeO/TFc0BGmQ8gfqzpQN2DPbNyEDmU9gfRMCICz+FxMfknpzadkNhzTvoK3xIYQg7MGJsRi0NXmCihtuwOD6kCwR1oDFWPCEXA19CmAOdlSMReiEEpc4Qw0hvRESLGfMKB1ChW87VQEJmRNrUADnQKirS+EjJIJQAWQcbxpCOzf6mKeRkKsjZAwgg+jjs0a48HEsHyEt2SJMAPm2wDiEWOQUPkJ6ItQC5AM3LKEN0St4HQjpjRiLgx0h/RLao8vODUIGIlQAT+CYsr4IrXMKHyEDUyAs2P4BTh/fhQxxnwCl8BEyAqHDLLQVyN7gOKSPPNnSZppiEnKdxMShtBWYT1LS+ZDDPxdiM7FhIWQCMsQ/rDtwYHSTDOE96qZFzdlZCJmYR8S5abQEa9rUHYeyEJIQbVw2Hai/xgf5EWHv5dLaI2QmtLFktCV46eMDM7QTvQ8ot/gaGwlCZkVbK/ADShjWuJwHPYM6n5hhK836YIyUkJnR1grULt4r5vtd3ju0Fzxae4RcADnC30mVrJ8t0v+M5R1UOdsKvk5bpH2ehJAI+hBBUwyfMa1VWECJ8TOUi99V8D7AYUAEwJepC0AGIwfwBOChxzzfARyr33cAP6vfXx3yXAK4qf6+AXBrpEWHfG3soerk757zJTOE4nf5DCGCNrQY+tACNyZHqPOn6BFyhWh3uA+3cS7pAL6WRggx6KvDIMV0gOr9znurLULIRVJAdSaUmF64KHiEkElYYj5CSMEjnWCHB3GRQXVMrFD3vI7dUQHUPco6HcGOC9IDFD8SSwH7UJQF2g9NOVYJqMVuXy370TJPQkQofmQotOXogtYbIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQq6NOb3b+4z6XdE/IrZbAvgWeax3xM9g8gLgT6iZgx+EfPVU79/Q/tsXJdQkAi8A/tVYl6OeJOCh8QsAbwD+K+SdVduYmPXtug6h18dkV/2+A/i3YxuzPvV2zWt6xOd6aLLF+cQLXwF8txzDXC7dO+a1fDP2cZX9q2MbiWaZzWO76itk/z2A/zj22TX+v4d8nz5W22heoJ4D0iM71HO5xWxXIH6uuF2LfTbV8TaB25+gZlSO5c7IY2lZ/2zkbytP6cl/bSmries6hF4fE7O+fWU5oP6CnO2aSvP65ZbtC2P9xrE85t55tBzXla+PJdT5SscrYb/+ofu/wv5FvuZ2a09Zy8b2G3nzdPjn1AUYgZ9QLZ2J+RGdI2pLSfNuyce3T/N/QLWC5nJzKqibav0CcRagbmWPsFsSen3TetMsoB4OlxVy71g+Nmuo+gHU9VhBrqd7uC3aPs5pj/o+ukX9xTn9t7YQJas6hDucX7sXnN9DN1BW5KIqzwLn9eLb/xaqPu6r5c39m9zDbckt0f8X9oiFtpafDbNFD22pQvfxtfYZzr+ra7MYXGSe/WxWoc0S3Tryt1lIU1h+LotPY7PISuE4TeukjeXnuuZmnTct0DaWn1lW1zHN++c5cv8MyupzbWO7/jnsbC3bzsby+8fUBbhCfkG13BptlWRQD0gBtztjWjA2y85nFR4t+bjyPzq2GRozzhZi8R2r3wXs9WZaJ0fL+q78hfOY6lOHvNaoy/oCd1zuK+p4o3nNQvb/BeD/UVuxX2F3f4/G37775ehYnzQUv2mwPcy3qF0rV5Bdi+YbPs9wnKF+CF376+U3sMcb9f56uvixWUKd/w3ChA9QD7kWggfLenOZKxTQlT+NMqw65PNg/P0kbPerOs6qsU/o/kAdUriBvd6OqOvLtv4Otes/VL0OylxjfpJpvRirEB0wXSBbfNFGjjrmKFl9rvX6WEeoOrqHslps+X/D8B85b2IK30+ECZ/mDaq89/jcC6rr5QVhH1VvixbrRYc8VtXvHv7p+22Wfcz+5n33AHus8g2q/m6h7g8zT9Pqe8O5NzML5ip+T1MXIBDbcJlbnJdfC5XZMWMTxK/GdrYAtGQVmnyr0j3Oh4c0xfNByKNvFqiFD9WvFGhvosV6gfPOHNPlfcM0H2AKxYyrhTaIXfb/DnUvmR15Tf6Eqlt9PUyB9HWsJQ/d3mH5htqV1UnfTICyRvS3LL5DjY/7A/YxXNLN5rMKTfT6puv7YKxvO/6wLQvUFp+2zr4h/LOU3/F5bKP590+cW7kpsjD+bmOhttk/RCRtrq/p8r4EHis55ip+X4S0n65YwRyhbibfwFzNHeqb2xbP81mFJj9Q39BaUGPEcyi0q/tU/X8TWRZdL6YFOyfrxBSiNhZqm/1X1e9R2EbXq3Z9AX/H2iyYq/jNhRXsAv1/iBsF/1D9vsN+s+n1L4H5ma15hnPxnEIotPB9h3Kt9tXyW4QPndDlXkA1FmaD8dK5hH5u/JuI/EJtsYWIV3NoUez+ptW/F7YzrWrdM/xQ/f8ScJxkofilT4bzoH2TNi6I2Tt5j3MLaWyXF/gs6g+oy/cE99Afk6ZFa1onQ38ms0AtOPsO+eh9F/C/WaGPd2y5/8r42+ZNwLLerFeA4kcG5sH4+0VY77IKXWiheMJ5p0AK/MDnTiHbWLQmNvEb+pwynIuHT0gkzH2f4D7nDezDTEL3XyLuvjGt6idjv1l/UJ7ilw7m2wTmGw8P1a/NKvNZhRL6QVlUv312ChSeFILp/i4QJiraor1B/wH5BT6fxxbnk2DsEVaH5psfplv/N86FZo/z+sqg3ux5qv4/4ryR8O0PKItwj7p+QurVtKoX1e9LwH5JM9ehLtfCEvWD9WJZ/2D8bVsvoWM5i5b7S+w960NnE3qAEpeb6u83+MXFHKYTaw37yvIgrD961scc5w3KLb2FqstjlVbGdj9hn3FF2v8W57HJbwiPPb/hglxegJZf6jxUvy6rTK9vG6szW/2XFvsPTdP9fYF/+MvY53SE6gi4RT9u4C+o4U5fUcc9FzgXPi1uNmGX9tfCd6z+D5kWS2PGiaeKDffKnObzu0YeUb/q1RQ/s5f2DTMeckBECtTCp3vjY0TW3P+IsLc/CCGEEEIIIYQQQgghhBBCCCGEkET5HyJ2wvPg0OQHAAAAAElFTkSuQmCC"
		
		private var logo_mc:Sprite;
		
		private var glow:GlowFilter = new GlowFilter(0x00ffff, 1, 1, 1, 100, 1, false, true);
		private var glow2:GlowFilter = new GlowFilter(0x00ffff, 0.6, 8, 8, 2, 1, false, false);
		private var glow3:GlowFilter = new GlowFilter(0x6666ff, 0.8, 10, 10, 3, 1, false, false);
		
		private var offset_y:Number = 2;
		private var offset_x:Number = 2;
		private var bounds:Object
		private var w:Number;
		private var h:Number;
		
		private var _sourceBmp		:BitmapData;
		private var _displaceBmp	:BitmapData;		
		private var _perlinNoiseBmp	:BitmapData;
			
		private var _offsetArray:Array = [new Point(), new Point()];
		private var _displacementFilter:DisplacementMapFilter;
		public function Elect() {
			
			logo_mc = new Sprite();
			logo_mc.addChild( Base64ImageLoader.load(data)  );			
			setTimeout( _timeout , 100 );			
		}		
		
		private function _timeout():void {
			logo_mc.x = (465 -logo_mc.width) >> 1;
			logo_mc.y = (465 -logo_mc.height) >> 1;
			addChild(logo_mc);
			bounds = logo_mc.getBounds(logo_mc);
			w = bounds.width + offset_x;
			h = bounds.height + offset_y;
			_sourceBmp = new BitmapData(w, h, true, 0);
			_displaceBmp = new BitmapData(w, h, true, 0);		
			_perlinNoiseBmp = new BitmapData(w, h);
			
			var bitmap:Bitmap = new Bitmap(_displaceBmp);
			bounds.x -= offset_x / 2;
			bounds.y -= offset_y / 2;
			_sourceBmp.draw(logo_mc, new Matrix(1, 0, 0, 1, bounds.x * -1, bounds.y * -1));
			
			this.addChild(bitmap)
			bitmap.x = logo_mc.x + bounds.x;
			bitmap.y = logo_mc.y + bounds.y;
			
			_displacementFilter = new DisplacementMapFilter(_perlinNoiseBmp, new Point(), 1, 1, 25, 25,DisplacementMapFilterMode.COLOR);
		
			logo_mc.filters = [glow2];
			bitmap.blendMode = BlendMode.SCREEN;
			bitmap.filters = [glow2, glow3];
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		private function enterFrameHandler(e:Event):void {			
			_offsetArray[0].x -= 2;
			_offsetArray[1].x -= 1;
			_perlinNoiseBmp.perlinNoise(10, 20, 3, 64, true, true, 1, true, _offsetArray);
			_displaceBmp.applyFilter(_sourceBmp, _sourceBmp.rect,new Point(), glow);
			_displaceBmp.applyFilter(_displaceBmp, _sourceBmp.rect, new Point(), _displacementFilter);
		}
	}
	
}


import flash.display.Loader;
import flash.utils.ByteArray;
import mx.utils.Base64Decoder;
class Base64ImageLoader {    
    public static function load(pData:String):Loader {
        var _byteArray:ByteArray;
        var _base64Decoder:Base64Decoder = new Base64Decoder();
        var _loader:Loader;                
        _base64Decoder.decode(pData);        
        try {
            _byteArray = _base64Decoder.toByteArray();
            _byteArray.position = 0;
        } catch (e:Error) {
            return null;
        }
        
        _loader = new Loader();
        _loader.loadBytes(_byteArray);
        
        return _loader;
    }
}