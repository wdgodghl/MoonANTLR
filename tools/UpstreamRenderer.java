import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import org.stringtemplate.v4.*;

/** Render the unmodified upstream descriptor grammar with its Java templates. */
public final class UpstreamRenderer {
    public static void main(String[] args) throws Exception {
        STGroup group=new STGroupFile(args[0],"UTF-8",'<','>');
        String grammar=Files.readString(Path.of(args[1]),StandardCharsets.UTF_8);
        String rendered=new ST(group,grammar).render().replace("outStream","System.out").replace("\r\n","\n");
        Files.writeString(Path.of(args[2]),rendered,StandardCharsets.UTF_8);
    }
}
