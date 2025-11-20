import java.io.*;

public class MagTransform {
	public static void main(String[] args) {
		try {
			if(args.length < 3) {
				System.out.println("Usage [move amount] [infile] [outfile]");
				return;
			}
			String[] moveAmountComponents = args[0].split(",");
			int moveAmountX = Integer.parseInt(moveAmountComponents[0]);
			int moveAmountY = Integer.parseInt(moveAmountComponents[1]);
			File infile = new File(args[1]);
			File outfile = new File(args[2]);
			BufferedReader br = new BufferedReader(new FileReader(infile));
			BufferedWriter bw = new BufferedWriter(new FileWriter(outfile));
			String currentLayer = "";
			while(true) {
				String line = br.readLine();
				if(line == null) break;
				if(line.startsWith("rect")) {
					String[] parts = line.split(" ");
					int x1 = Integer.parseInt(parts[1]);
					int y1 = Integer.parseInt(parts[2]);
					int x2 = Integer.parseInt(parts[3]);
					int y2 = Integer.parseInt(parts[4]);
					y1 += moveAmountY;
					y2 += moveAmountY;
					x1 += moveAmountX;
					x2 += moveAmountX;
					line = parts[0] + " " + x1 + " " + y1 + " " + x2 + " " + y2;
				}
				if(line.startsWith("flabel")) {
					String[] parts = line.split(" ");
					String name = parts[parts.length - 1];
					{
						int numIdx = 2;
						if(parts.length == 14) numIdx = 3;
						int x1 = Integer.parseInt(parts[numIdx]);
						int y1 = Integer.parseInt(parts[numIdx+1]);
						int x2 = Integer.parseInt(parts[numIdx+2]);
						int y2 = Integer.parseInt(parts[numIdx+3]);
						y1 += moveAmountY;
						y2 += moveAmountY;
						x1 += moveAmountX;
						x2 += moveAmountX;
						line = "";
						parts[numIdx] = Integer.toString(x1);
						parts[numIdx+1] = Integer.toString(y1);
						parts[numIdx+2] = Integer.toString(x2);
						parts[numIdx+3] = Integer.toString(y2);
						for(int i = 0; i < parts.length; i++) {
							line += parts[i];
							if(i != parts.length - 1) line += " ";
						}
					}
				}
				if(line.startsWith("transform")) {
					String[] parts = line.split(" ");
					int x1 = Integer.parseInt(parts[3]);
					int y1 = Integer.parseInt(parts[6]);
					x1 += moveAmountX;
					y1 += moveAmountY;
					parts[3] = Integer.toString(x1);
					parts[6] = Integer.toString(y1);
					line = "";
					for(int i = 0; i < parts.length; i++) {
						line += parts[i];
						if(i != parts.length - 1) line += " ";
					}
				}
				if(line.startsWith("<< ")) currentLayer = line.split(" ")[1];
				bw.write(line);
				bw.newLine();
			}
			bw.close();
			br.close();
		}catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
